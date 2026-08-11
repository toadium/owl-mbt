///|
/// Generic 2D pooling helper.
/// init_fn: called at start of each output position
/// add_fn: called for each valid input element in the window
/// end_fn: called to get the final result
fn _pool2d(
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  padding : @types.Padding,
  init_fn : () -> Unit,
  add_fn : (Double) -> Unit,
  end_fn : () -> Double,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let in_channel = input_shp[3]
  let kernel_cols = kernel[0]
  let kernel_rows = kernel[1]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let (output_cols, output_rows) = _calc_conv2d_output_shape(
    padding, input_cols, input_rows, kernel_cols, kernel_rows, row_stride, col_stride,
  )
  let out_data = FixedArray::make(
    batches * output_cols * output_rows * in_channel,
    0.0,
  )
  let (pad_top, pad_left, _, _) = _calc_conv2d_padding(
    input_cols, input_rows, kernel_cols, kernel_rows, output_cols, output_rows, row_stride,
    col_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for k in 0..<in_channel {
          init_fn()
          for di in 0..<kernel_cols {
            for dj in 0..<kernel_rows {
              let in_col = i * col_stride + di - pad_left
              let in_row = j * row_stride + dj - pad_top
              if in_col >= 0 &&
                in_col < input_cols &&
                in_row >= 0 &&
                in_row < input_rows {
                let in_idx = b * (input_cols * input_rows * in_channel) +
                  in_col * (input_rows * in_channel) +
                  in_row * in_channel +
                  k
                add_fn(input.data[in_idx])
              }
            }
          }
          let out_idx = b * (output_cols * output_rows * in_channel) +
            i * (output_rows * in_channel) +
            j * in_channel +
            k
          out_data[out_idx] = end_fn()
        }
      }
    }
  }
  { shape: [batches, output_cols, output_rows, in_channel], data: out_data }
}

///|
/// Generic 3D pooling helper.
fn _pool3d(
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  padding : @types.Padding,
  init_fn : () -> Unit,
  add_fn : (Double) -> Unit,
  end_fn : () -> Double,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let input_dpts = input_shp[3]
  let in_channel = input_shp[4]
  let kernel_cols = kernel[0]
  let kernel_rows = kernel[1]
  let kernel_dpts = kernel[2]
  let col_stride = stride[0]
  let row_stride = stride[1]
  let dpt_stride = stride[2]
  let (output_cols, output_rows, output_dpts) = _calc_conv3d_output_shape(
    padding, input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts,
    row_stride, col_stride, dpt_stride,
  )
  let total = batches * output_cols * output_rows * output_dpts * in_channel
  let out_data = FixedArray::make(total, 0.0)
  let (pad_top, pad_left, pad_shallow, _, _, _) = _calc_conv3d_padding(
    input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts, output_cols,
    output_rows, output_dpts, row_stride, col_stride, dpt_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for dpt in 0..<output_dpts {
          for k in 0..<in_channel {
            init_fn()
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
                    let in_idx = b *
                      (input_cols * input_rows * input_dpts * in_channel) +
                      in_col * (input_rows * input_dpts * in_channel) +
                      in_row * (input_dpts * in_channel) +
                      in_dpt * in_channel +
                      k
                    add_fn(input.data[in_idx])
                  }
                }
              }
            }
            let out_idx = b *
              (output_cols * output_rows * output_dpts * in_channel) +
              i * (output_rows * output_dpts * in_channel) +
              j * (output_dpts * in_channel) +
              dpt * in_channel +
              k
            out_data[out_idx] = end_fn()
          }
        }
      }
    }
  }
  {
    shape: [batches, output_cols, output_rows, output_dpts, in_channel],
    data: out_data,
  }
}

///|
/// 2D max pooling.
/// input:  [batch, in_col, in_row, in_channel]
/// kernel: [k_col, k_row]
/// stride: [col_stride, row_stride]
/// output: [batch, out_col, out_row, in_channel]
pub fn max_pool2d(
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray {
  let mut max_val = 0.0
  _pool2d(
    input,
    kernel,
    stride,
    padding,
    fn() { max_val = -1.7976931348623157e308 },
    fn(v) { if v > max_val { max_val = v } },
    fn() { max_val },
  )
}

///|
/// 1D max pooling (via reshape to 2D).
pub fn max_pool1d(
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_cols = kernel[0]
  let kernel_2d = [1, kernel_cols]
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output = max_pool2d(input_4d, kernel_2d, stride_2d, padding~)
  let output_shp = output.shape
  let output_cols = output_shp[2]
  reshape(output, [batches, output_cols, in_channel])
}

///|
/// 3D max pooling.
pub fn max_pool3d(
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray {
  let mut max_val = 0.0
  _pool3d(
    input,
    kernel,
    stride,
    padding,
    fn() { max_val = -1.7976931348623157e308 },
    fn(v) { if v > max_val { max_val = v } },
    fn() { max_val },
  )
}

///|
/// 2D average pooling.
pub fn avg_pool2d(
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray {
  let mut sum_val = 0.0
  let mut cnt = 0
  _pool2d(
    input,
    kernel,
    stride,
    padding,
    fn() {
      sum_val = 0.0
      cnt = 0
    },
    fn(v) {
      sum_val += v
      cnt += 1
    },
    fn() {
      if cnt == 0 {
        0.0
      } else {
        sum_val / cnt.to_double()
      }
    },
  )
}

///|
/// 1D average pooling (via reshape to 2D).
pub fn avg_pool1d(
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray raise {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let kernel_cols = kernel[0]
  let kernel_2d = [1, kernel_cols]
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output = avg_pool2d(input_4d, kernel_2d, stride_2d, padding~)
  let output_shp = output.shape
  let output_cols = output_shp[2]
  reshape(output, [batches, output_cols, in_channel])
}

///|
/// 3D average pooling.
pub fn avg_pool3d(
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  padding? : @types.Padding = @types.Padding::Same,
) -> Ndarray {
  let mut sum_val = 0.0
  let mut cnt = 0
  _pool3d(
    input,
    kernel,
    stride,
    padding,
    fn() {
      sum_val = 0.0
      cnt = 0
    },
    fn(v) {
      sum_val += v
      cnt += 1
    },
    fn() {
      if cnt == 0 {
        0.0
      } else {
        sum_val / cnt.to_double()
      }
    },
  )
}

///|
/// 2D upsampling (nearest neighbor).
/// input: [batch, in_col, in_row, in_channel]
/// size:  [col_scale, row_scale]
/// output: [batch, in_col*col_scale, in_row*row_scale, in_channel]
pub fn upsampling2d(input : Ndarray, size : Array[Int]) -> Ndarray {
  repeat(input, [1, size[0], size[1], 1])
}
