///|
/// Dilated conv1d backward input.
pub fn dilated_conv1d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let upsampled = _upsample_kernel2d(
    reshape(kernel, [1, kernel.shape[0], kernel.shape[1], kernel.shape[2]]),
    rate,
  )
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let in_channel = input_shp[2]
  let input_4d = reshape(input, [batches, 1, input_cols, in_channel])
  let col_stride = stride[0]
  let stride_2d = [1, col_stride]
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    output_grad.shape[2],
  ])
  let result = conv2d_backward_input(
    input_4d, upsampled, stride_2d, output_grad_4d,
  )
  reshape(result, [batches, input_cols, in_channel])
}

///|
/// Dilated conv1d backward kernel.
pub fn dilated_conv1d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
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
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    out_channel,
  ])
  let grad_4d = conv2d_backward_kernel(
    input_4d, kernel_4d, stride_2d, output_grad_4d,
  )
  let downsampled = _downsample_kernel2d(grad_4d, rate)
  reshape(downsampled, [kernel_cols, in_channel, out_channel])
}

///|
/// Downsample a 2D kernel (inverse of upsample).
fn _downsample_kernel2d(kernel : Ndarray, rate : Array[Int]) -> Ndarray {
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
  let col_down = (kernel_cols + col_rate - 1) / col_rate
  let row_down = (kernel_rows + row_rate - 1) / row_rate
  let new_data = FixedArray::make(
    col_down * row_down * in_channel * out_channel,
    0.0,
  )
  for c in 0..<col_down {
    for r in 0..<row_down {
      for i in 0..<in_channel {
        for o in 0..<out_channel {
          let v = kernel.data[c *
            col_rate *
            (kernel_rows * in_channel * out_channel) +
            r * row_rate * (in_channel * out_channel) +
            i * out_channel +
            o]
          new_data[c * (row_down * in_channel * out_channel) +
          r * (in_channel * out_channel) +
          i * out_channel +
          o] = v
        }
      }
    }
  }
  { shape: [col_down, row_down, in_channel, out_channel], data: new_data }
}

///|
/// Dilated conv2d backward input.
#warnings("-unused_error_type")
pub fn dilated_conv2d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let upsampled = _upsample_kernel2d(kernel, rate)
  conv2d_backward_input(input, upsampled, stride, output_grad)
}

///|
/// Dilated conv2d backward kernel.
#warnings("-unused_error_type")
pub fn dilated_conv2d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let kernel_4d = kernel
  let grad = conv2d_backward_kernel(input, kernel_4d, stride, output_grad)
  _downsample_kernel2d(grad, rate)
}

///|
/// Downsample a 3D kernel.
fn _downsample_kernel3d(kernel : Ndarray, rate : Array[Int]) -> Ndarray {
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
  let col_down = (kernel_cols + col_rate - 1) / col_rate
  let row_down = (kernel_rows + row_rate - 1) / row_rate
  let dpt_down = (kernel_dpts + dpt_rate - 1) / dpt_rate
  let total = col_down * row_down * dpt_down * in_channel * out_channel
  let new_data = FixedArray::make(total, 0.0)
  for c in 0..<col_down {
    for r in 0..<row_down {
      for d in 0..<dpt_down {
        for i in 0..<in_channel {
          for o in 0..<out_channel {
            let v = kernel.data[c *
              col_rate *
              (kernel_rows * kernel_dpts * in_channel * out_channel) +
              r * row_rate * (kernel_dpts * in_channel * out_channel) +
              d * dpt_rate * (in_channel * out_channel) +
              i * out_channel +
              o]
            new_data[c * (row_down * dpt_down * in_channel * out_channel) +
            r * (dpt_down * in_channel * out_channel) +
            d * (in_channel * out_channel) +
            i * out_channel +
            o] = v
          }
        }
      }
    }
  }
  {
    shape: [col_down, row_down, dpt_down, in_channel, out_channel],
    data: new_data,
  }
}

///|
/// Dilated conv3d backward input.
#warnings("-unused_error_type")
pub fn dilated_conv3d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let upsampled = _upsample_kernel3d(kernel, rate)
  conv3d_backward_input(input, upsampled, stride, output_grad)
}

///|
/// Dilated conv3d backward kernel.
#warnings("-unused_error_type")
pub fn dilated_conv3d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  rate : Array[Int],
  output_grad : Ndarray,
) -> Ndarray raise {
  let grad = conv3d_backward_kernel(input, kernel, stride, output_grad)
  _downsample_kernel3d(grad, rate)
}
