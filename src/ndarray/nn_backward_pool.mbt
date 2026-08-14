///|
/// Max pool 2d backward.
/// Note: parameter order differs from the forward `max_pool2d` — `padding`
/// is the first parameter here (required) vs the last parameter in the forward
/// (optional). This is faithfully ported from the OCaml source.
pub fn max_pool2d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
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
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, _, _) = _calc_conv2d_padding(
    input_cols, input_rows, kernel_cols, kernel_rows, output_cols, output_rows, row_stride,
    col_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for k in 0..<in_channel {
          let mut max_val = -1.7976931348623157e308
          let mut max_in_col = -1
          let mut max_in_row = -1
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
                if input.data[in_idx] > max_val {
                  max_val = input.data[in_idx]
                  max_in_col = in_col
                  max_in_row = in_row
                }
              }
            }
          }
          if max_in_col >= 0 {
            let out_grad_idx = b * (output_cols * output_rows * in_channel) +
              i * (output_rows * in_channel) +
              j * in_channel +
              k
            let in_idx = b * (input_cols * input_rows * in_channel) +
              max_in_col * (input_rows * in_channel) +
              max_in_row * in_channel +
              k
            in_grad[in_idx] += output_grad.data[out_grad_idx]
          }
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// Max pool 1d backward.
pub fn max_pool1d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
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
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    in_channel,
  ])
  let result = max_pool2d_backward(
    padding, input_4d, kernel_2d, stride_2d, output_grad_4d,
  )
  reshape(result, [batches, input_cols, in_channel])
}

///|
/// Max pool 3d backward.
pub fn max_pool3d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
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
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, pad_shallow, _, _, _) = _calc_conv3d_padding(
    input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts, output_cols,
    output_rows, output_dpts, row_stride, col_stride, dpt_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for dpt in 0..<output_dpts {
          for k in 0..<in_channel {
            let mut max_val = -1.7976931348623157e308
            let mut max_idx = -1
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
                    if input.data[in_idx] > max_val {
                      max_val = input.data[in_idx]
                      max_idx = in_idx
                    }
                  }
                }
              }
            }
            if max_idx >= 0 {
              let out_grad_idx = b *
                (output_cols * output_rows * output_dpts * in_channel) +
                i * (output_rows * output_dpts * in_channel) +
                j * (output_dpts * in_channel) +
                dpt * in_channel +
                k
              in_grad[max_idx] += output_grad.data[out_grad_idx]
            }
          }
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// Avg pool 2d backward.
pub fn avg_pool2d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
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
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, _, _) = _calc_conv2d_padding(
    input_cols, input_rows, kernel_cols, kernel_rows, output_cols, output_rows, row_stride,
    col_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for k in 0..<in_channel {
          let mut cnt = 0
          for di in 0..<kernel_cols {
            for dj in 0..<kernel_rows {
              let in_col = i * col_stride + di - pad_left
              let in_row = j * row_stride + dj - pad_top
              if in_col >= 0 &&
                in_col < input_cols &&
                in_row >= 0 &&
                in_row < input_rows {
                cnt += 1
              }
            }
          }
          let grad_per = if cnt > 0 {
            let out_grad_idx = b * (output_cols * output_rows * in_channel) +
              i * (output_rows * in_channel) +
              j * in_channel +
              k
            output_grad.data[out_grad_idx] / cnt.to_double()
          } else {
            0.0
          }
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
                in_grad[in_idx] += grad_per
              }
            }
          }
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// Avg pool 1d backward.
pub fn avg_pool1d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
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
  let output_grad_4d = reshape(output_grad, [
    batches,
    1,
    output_grad.shape[1],
    in_channel,
  ])
  let result = avg_pool2d_backward(
    padding, input_4d, kernel_2d, stride_2d, output_grad_4d,
  )
  reshape(result, [batches, input_cols, in_channel])
}

///|
/// Avg pool 3d backward.
pub fn avg_pool3d_backward(
  padding : @types.Padding,
  input : Ndarray,
  kernel : Array[Int],
  stride : Array[Int],
  output_grad : Ndarray,
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
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  let (pad_top, pad_left, pad_shallow, _, _, _) = _calc_conv3d_padding(
    input_cols, input_rows, input_dpts, kernel_cols, kernel_rows, kernel_dpts, output_cols,
    output_rows, output_dpts, row_stride, col_stride, dpt_stride,
  )
  for b in 0..<batches {
    for i in 0..<output_cols {
      for j in 0..<output_rows {
        for dpt in 0..<output_dpts {
          for k in 0..<in_channel {
            let mut cnt = 0
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
                    cnt += 1
                  }
                }
              }
            }
            let grad_per = if cnt > 0 {
              let out_grad_idx = b *
                (output_cols * output_rows * output_dpts * in_channel) +
                i * (output_rows * output_dpts * in_channel) +
                j * (output_dpts * in_channel) +
                dpt * in_channel +
                k
              output_grad.data[out_grad_idx] / cnt.to_double()
            } else {
              0.0
            }
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
                    in_grad[in_idx] += grad_per
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}

///|
/// Upsampling 2d backward.
pub fn upsampling2d_backward(
  input : Ndarray,
  size : Array[Int],
  output_grad : Ndarray,
) -> Ndarray {
  let input_shp = input.shape
  let batches = input_shp[0]
  let input_cols = input_shp[1]
  let input_rows = input_shp[2]
  let in_channel = input_shp[3]
  let col_scale = size[0]
  let row_scale = size[1]
  let in_grad = FixedArray::make(input.data.length(), 0.0)
  for b in 0..<batches {
    for c in 0..<input_cols {
      for r in 0..<input_rows {
        for k in 0..<in_channel {
          let mut sum = 0.0
          for dc in 0..<col_scale {
            for dr in 0..<row_scale {
              let out_col = c * col_scale + dc
              let out_row = r * row_scale + dr
              let out_idx = b *
                (input_cols * col_scale * input_rows * row_scale * in_channel) +
                out_col * (input_rows * row_scale * in_channel) +
                out_row * in_channel +
                k
              sum += output_grad.data[out_idx]
            }
          }
          let in_idx = b * (input_cols * input_rows * in_channel) +
            c * (input_rows * in_channel) +
            r * in_channel +
            k
          in_grad[in_idx] = sum
        }
      }
    }
  }
  { shape: input_shp.copy(), data: in_grad }
}
