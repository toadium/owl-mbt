///|
/// Transpose conv1d backward input.
pub fn transpose_conv1d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
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
  let transposed_kernel = _transpose_axis(kernel_4d, [0, 1, 3, 2])
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    out_channel,
  ])
  let result = conv2d_backward_kernel(
    input_4d, transposed_kernel, stride_2d, output_grad_4d,
  )
  reshape(result, [batches, input_cols, in_channel])
}

///|
/// Transpose conv1d backward kernel.
pub fn transpose_conv1d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
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
  let transposed_kernel = _transpose_axis(kernel_4d, [0, 1, 3, 2])
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    out_channel,
  ])
  let result = conv2d_backward_input(
    output_grad_4d, transposed_kernel, stride_2d, input_4d,
  )
  reshape(result, [kernel_cols, in_channel, out_channel])
}

///|
/// Transpose conv2d backward input.
pub fn transpose_conv2d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 3, 2])
  conv2d_backward_kernel(input, transposed_kernel, stride, output_grad)
}

///|
/// Transpose conv2d backward kernel.
pub fn transpose_conv2d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 3, 2])
  conv2d_backward_input(output_grad, transposed_kernel, stride, input)
}

///|
/// Transpose conv3d backward input.
pub fn transpose_conv3d_backward_input(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 2, 4, 3])
  conv3d_backward_kernel(input, transposed_kernel, stride, output_grad)
}

///|
/// Transpose conv3d backward kernel.
pub fn transpose_conv3d_backward_kernel(
  input : Ndarray,
  kernel : Ndarray,
  stride : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let transposed_kernel = _transpose_axis(kernel, [0, 1, 2, 4, 3])
  conv3d_backward_input(output_grad, transposed_kernel, stride, input)
}
