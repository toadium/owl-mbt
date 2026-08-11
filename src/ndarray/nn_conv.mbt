///|
/// Calculate conv2d output shape.
/// Returns (output_cols, output_rows).
fn _calc_conv2d_output_shape(
  padding : @types.Padding,
  input_cols : Int,
  input_rows : Int,
  kernel_cols : Int,
  kernel_rows : Int,
  row_stride : Int,
  col_stride : Int,
) -> (Int, Int) {
  let output_cols = match padding {
    @types.Padding::Same => _ceil_div(input_cols, col_stride)
    @types.Padding::Valid => _ceil_div(input_cols - kernel_cols + 1, col_stride)
  }
  let output_rows = match padding {
    @types.Padding::Same => _ceil_div(input_rows, row_stride)
    @types.Padding::Valid => _ceil_div(input_rows - kernel_rows + 1, row_stride)
  }
  (output_cols, output_rows)
}

///|
/// Ceiling division: ceil(a / b).
fn _ceil_div(a : Int, b : Int) -> Int {
  (a + b - 1) / b
}

///|
/// Calculate conv2d padding.
/// Returns (pad_top, pad_left, pad_bottom, pad_right).
fn _calc_conv2d_padding(
  input_cols : Int,
  input_rows : Int,
  kernel_cols : Int,
  kernel_rows : Int,
  output_cols : Int,
  output_rows : Int,
  row_stride : Int,
  col_stride : Int,
) -> (Int, Int, Int, Int) {
  let pad_along_height = _max0(
    (output_rows - 1) * row_stride + kernel_rows - input_rows,
  )
  let pad_along_width = _max0(
    (output_cols - 1) * col_stride + kernel_cols - input_cols,
  )
  let pad_top = pad_along_height / 2
  let pad_bottom = pad_along_height - pad_top
  let pad_left = pad_along_width / 2
  let pad_right = pad_along_width - pad_left
  (pad_top, pad_left, pad_bottom, pad_right)
}

///|
fn _max0(x : Int) -> Int {
  if x > 0 {
    x
  } else {
    0
  }
}

///|
/// Calculate transpose conv2d output shape.
/// Returns (output_cols, output_rows).
fn _calc_transpose_conv2d_output_shape(
  padding : @types.Padding,
  input_cols : Int,
  input_rows : Int,
  kernel_cols : Int,
  kernel_rows : Int,
  row_stride : Int,
  col_stride : Int,
) -> (Int, Int) {
  let output_cols = match padding {
    @types.Padding::Same => input_cols * col_stride
    @types.Padding::Valid =>
      input_cols * col_stride + _max0(kernel_cols - col_stride)
  }
  let output_rows = match padding {
    @types.Padding::Same => input_rows * row_stride
    @types.Padding::Valid =>
      input_rows * row_stride + _max0(kernel_rows - row_stride)
  }
  (output_cols, output_rows)
}

///|
/// 2D convolution.
/// input:  [batch, in_col, in_row, in_channel]
/// kernel: [k_col, k_row, in_channel, out_channel]
/// stride: [col_stride, row_stride]
/// output: [batch, out_col, out_row, out_channel]
#warnings("-unused_error_type")
pub fn conv2d(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let in_channel = input_shp[3]
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let out_channel = kernel_shp[3]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let (output_cols, output_rows) = _calc_conv2d_output_shape(
    padding, input_cols, input_rows, kernel_cols, kernel_rows, row_stride, col_stride,
  )
  let out_data = FixedArray::make(
    batches * output_cols * output_rows * out_channel,
    0.0,
  )
  let (pad_top, pad_left, _, _) = _calc_conv2d_padding(
    input_cols, input_rows, kernel_cols, kernel_rows, output_cols, output_rows, row_stride,
    col_stride,
  )
  let in_stride = input_cols * input_rows * in_channel
  let col_in_stride = input_rows * in_channel
  let k_col_stride = kernel_rows * in_channel * out_channel
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for k in 0..<out_channel {
          let mut sum = 0.0
          for di in 0..<kernel_cols {
            for dj in 0..<kernel_rows {
              let in_col = i * col_stride + di - pad_left
              let in_row = j * row_stride + dj - pad_top
              if in_col >= 0 &&
                in_col < input_cols &&
                in_row >= 0 &&
                in_row < input_rows {
                let in_base = b * in_stride +
                  in_col * col_in_stride +
                  in_row * in_channel
                let k_base = di * k_col_stride + dj * (in_channel * out_channel) + k
                for q in 0..<in_channel {
                  sum += input.data[in_base + q] *
                    kernel.data[k_base + q * out_channel]
                }
              }
            }
          }
          let out_idx = b * (output_cols * output_rows * out_channel) +
            i * (output_rows * out_channel) +
            j * out_channel +
            k
          out_data[out_idx] = sum
        }
      }
    }
  }
  { shape: [batches, output_cols, output_rows, out_channel], data: out_data }
}

///|
/// 1D convolution (via reshape to 2D).
/// input:  [batch, in_col, in_channel]
/// kernel: [k_col, in_channel, out_channel]
/// stride: [col_stride]
/// output: [batch, out_col, out_channel]
pub fn conv1d(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let out_channel = kernel_shp[2]
  let kernel_4d = reshape(kernel, [1, kernel_cols, in_channel, out_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output = conv2d(input_4d, kernel_4d, stride_2d, padding~)
  let output_shp = output.shape
  let output_cols = output_shp[2]
  reshape(output, [batches, output_cols, out_channel])
}

///|
/// Calculate conv3d output shape.
fn _calc_conv3d_output_shape(
  padding : @types.Padding,
  input_cols : Int,
  input_rows : Int,
  input_dpts : Int,
  kernel_cols : Int,
  kernel_rows : Int,
  kernel_dpts : Int,
  row_stride : Int,
  col_stride : Int,
  dpt_stride : Int,
) -> (Int, Int, Int) {
  let output_cols = match padding {
    @types.Padding::Same => _ceil_div(input_cols, col_stride)
    @types.Padding::Valid => _ceil_div(input_cols - kernel_cols + 1, col_stride)
  }
  let output_rows = match padding {
    @types.Padding::Same => _ceil_div(input_rows, row_stride)
    @types.Padding::Valid => _ceil_div(input_rows - kernel_rows + 1, row_stride)
  }
  let output_dpts = match padding {
    @types.Padding::Same => _ceil_div(input_dpts, dpt_stride)
    @types.Padding::Valid => _ceil_div(input_dpts - kernel_dpts + 1, dpt_stride)
  }
  (output_cols, output_rows, output_dpts)
}

///|
/// Calculate conv3d padding.
/// Returns (pad_top, pad_left, pad_shallow, pad_bottom, pad_right, pad_deep).
fn _calc_conv3d_padding(
  input_cols : Int,
  input_rows : Int,
  input_depth : Int,
  kernel_cols : Int,
  kernel_rows : Int,
  kernel_depth : Int,
  output_cols : Int,
  output_rows : Int,
  output_depth : Int,
  row_stride : Int,
  col_stride : Int,
  depth_stride : Int,
) -> (Int, Int, Int, Int, Int, Int) {
  let pad_h = _max0((output_rows - 1) * row_stride + kernel_rows - input_rows)
  let pad_w = _max0((output_cols - 1) * col_stride + kernel_cols - input_cols)
  let pad_d = _max0(
    (output_depth - 1) * depth_stride + kernel_depth - input_depth,
  )
  let pad_top = pad_h / 2
  let pad_bottom = pad_h - pad_top
  let pad_left = pad_w / 2
  let pad_right = pad_w - pad_left
  let pad_shallow = pad_d / 2
  let pad_deep = pad_d - pad_shallow
  (pad_top, pad_left, pad_shallow, pad_bottom, pad_right, pad_deep)
}

///|
/// 3D convolution.
/// input:  [batch, in_col, in_row, in_dpt, in_channel]
/// kernel: [k_col, k_row, k_dpt, in_channel, out_channel]
/// stride: [col_stride, row_stride, dpt_stride]
/// output: [batch, out_col, out_row, out_dpt, out_channel]
#warnings("-unused_error_type")
pub fn conv3d(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let input_dpts = input_shp[3]
  let in_channel = input_shp[4]
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let kernel_dpts = kernel_shp[2]
  let out_channel = kernel_shp[4]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let dpt_stride = stride[2]
  let (output_cols, output_rows, output_dpts) = _calc_conv3d_output_shape(
    padding, input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts,
    row_stride, col_stride, dpt_stride,
  )
  let total = batches * output_cols * output_rows * output_dpts * out_channel
  let out_data = FixedArray::make(total, 0.0)
  let (pad_top, pad_left, pad_shallow, _, _, _) = _calc_conv3d_padding(
    input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts, output_cols,
    output_rows, output_dpts, row_stride, col_stride, dpt_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for dpt in 0..<output_dpts {
          for k in 0..<out_channel {
            let mut sum = 0.0
            for di in 0..<kernel_cols {
              for dj in 0..<kernel_rows {
                for d_dpt in 0..<kernel_dpts {
                  let in_col = i * col_stride + di - pad_left
                  let in_row = j * row_stride + dj - pad_top
                  let in_dpt = dpt * dpt_stride + d_dpt - pad_shallow
                  if in_col >= 0 &&
                    in_col < input_cols &&
                    in_row >= 0 &&
                    in_row < input_rows &&
                    in_dpt >= 0 &&
                    in_dpt < input_dpts {
                    for q in 0..<in_channel {
                      let in_idx = b *
                        (input_cols * input_rows * input_dpts * in_channel) +
                        in_col * (input_rows * input_dpts * in_channel) +
                        in_row * (input_dpts * in_channel) +
                        in_dpt * in_channel +
                        q
                      let k_idx = di *
                        (kernel_rows * kernel_dpts * in_channel * out_channel) +
                        dj * (kernel_dpts * in_channel * out_channel) +
                        d_dpt * (in_channel * out_channel) +
                        q * out_channel +
                        k
                      sum += input.data[in_idx] * kernel.data[k_idx]
                    }
                  }
                }
              }
            }
            let out_idx = b *
              (output_cols * output_rows * output_dpts * out_channel) +
              i * (output_rows * output_dpts * out_channel) +
              j * (output_dpts * out_channel) +
              dpt * out_channel +
              k
            out_data[out_idx] = sum
          }
        }
      }
    }
  }
  {
    shape: [batches, output_cols, output_rows, output_dpts, out_channel],
    data: out_data,
  }
}

///|
/// Upsample a 2D kernel by inserting zeros (for dilated convolution).
fn _upsample_kernel2d(kernel : Ndarray, rate : Array[Int]) -> Ndarray {
  if rate[0] == 1 && rate[1] == 1 {
    return kernel
  }
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let in_channel = kernel_shp[2]
  let out_channel = kernel_shp[3]
  let col_rate = rate[0]
  let row_rate = rate[1]
  let col_up = kernel_cols + (kernel_cols - 1) * (col_rate - 1)
  let row_up = kernel_rows + (kernel_rows - 1) * (row_rate - 1)
  let new_data = FixedArray::make(
    col_up * row_up * in_channel * out_channel,
    0.0,
  )
  for c in 0..<kernel_cols {
    for r in 0..<kernel_rows {
      for i in 0..<in_channel {
        for o in 0..<out_channel {
          let v = kernel.data[c * (kernel_rows * in_channel * out_channel) +
            r * (in_channel * out_channel) +
            i * out_channel +
            o]
          let new_idx = c * col_rate * (row_up * in_channel * out_channel) +
            r * row_rate * (in_channel * out_channel) +
            i * out_channel +
            o
          new_data[new_idx] = v
        }
      }
    }
  }
  { shape: [col_up, row_up, in_channel, out_channel], data: new_data }
}

///|
/// Upsample a 3D kernel by inserting zeros.
fn _upsample_kernel3d(kernel : Ndarray, rate : Array[Int]) -> Ndarray {
  if rate[0] == 1 && rate[1] == 1 && rate[2] == 1 {
    return kernel
  }
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let kernel_rows = kernel_shp[1]
  let kernel_dpts = kernel_shp[2]
  let in_channel = kernel_shp[3]
  let out_channel = kernel_shp[4]
  let col_rate = rate[0]
  let row_rate = rate[1]
  let dpt_rate = rate[2]
  let col_up = kernel_cols + (kernel_cols - 1) * (col_rate - 1)
  let row_up = kernel_rows + (kernel_rows - 1) * (row_rate - 1)
  let dpt_up = kernel_dpts + (kernel_dpts - 1) * (dpt_rate - 1)
  let total = col_up * row_up * dpt_up * in_channel * out_channel
  let new_data = FixedArray::make(total, 0.0)
  for c in 0..<kernel_cols {
    for r in 0..<kernel_rows {
      for d in 0..<kernel_dpts {
        for i in 0..<in_channel {
          for o in 0..<out_channel {
            let v = kernel.data[c *
              (kernel_rows * kernel_dpts * in_channel * out_channel) +
              r * (kernel_dpts * in_channel * out_channel) +
              d * (in_channel * out_channel) +
              i * out_channel +
              o]
            let new_idx = c *
              col_rate *
              (row_up * dpt_up * in_channel * out_channel) +
              r * row_rate * (dpt_up * in_channel * out_channel) +
              d * dpt_rate * (in_channel * out_channel) +
              i * out_channel +
              o
            new_data[new_idx] = v
          }
        }
      }
    }
  }
  { shape: [col_up, row_up, dpt_up, in_channel, out_channel], data: new_data }
}

///|
/// 2D dilated convolution.
pub fn dilated_conv2d(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let upsampled = _upsample_kernel2d(kernel, rate)
  conv2d(input, upsampled, stride, padding~)
}

///|
/// 1D dilated convolution (via reshape to 2D).
pub fn dilated_conv1d(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_shp = kernel.shape
  let kernel_cols = kernel_shp[0]
  let out_channel = kernel_shp[2]
  let kernel_4d = reshape(kernel, [1, kernel_cols, in_channel, out_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output = dilated_conv2d(input_4d, kernel_4d, stride_2d, rate, padding~)
  let output_shp = output.shape
  let output_cols = output_shp[2]
  reshape(output, [batches, output_cols, out_channel])
}

///|
/// 3D dilated convolution.
pub fn dilated_conv3d(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let upsampled = _upsample_kernel3d(kernel, rate)
  conv3d(input, upsampled, stride, padding~)
}
