///|
/// FFT：一维 radix-2 Cooley-Tukey 迭代实现（位反转置换 + 蝶形运算）。
/// 仅支持长度为 2 的幂的一维实数输入；输出复数以 (实部, 虚部) 两个 Ndarray 表示。
/// Owls 的 FFT 位于 fftpack（未移植范围），本实现为自行编写。

///|
/// 一维快速傅里叶变换。
/// 输入必须是一维、长度为 2 的幂（n >= 1）；否则 raise OwlError::InvalidArgument。
/// 返回 (实部, 虚部)，各为长度 n 的一维 Ndarray。
pub fn fft(x : Ndarray) -> (Ndarray, Ndarray) raise {
  if x.shape.length() != 1 {
    raise @core.OwlError::InvalidArgument("fft: input must be 1-dimensional")
  }
  let n = x.shape[0]
  if n < 1 || (n & (n - 1)) != 0 {
    raise @core.OwlError::InvalidArgument(
      "fft: length must be a power of two, got \{n}",
    )
  }
  let re : Array[Double] = []
  let im : Array[Double] = []
  for i in 0..<n {
    re.push(x.data[i])
    im.push(0.0)
  }
  _fft_inplace(re, im, false)
  (of_array(re, [n]), of_array(im, [n]))
}

///|
/// 一维快速傅里叶逆变换（含 1/n 归一化）。
/// 返回时域实序列；输入虚部的反变换虚残差被忽略（对频域 round-trip 而言可忽略）。
pub fn ifft(re_part : Ndarray, im_part : Ndarray) -> Ndarray raise {
  if re_part.shape.length() != 1 || im_part.shape.length() != 1 {
    raise @core.OwlError::InvalidArgument("ifft: inputs must be 1-dimensional")
  }
  let n = re_part.shape[0]
  if im_part.shape[0] != n {
    raise @core.OwlError::InvalidArgument("ifft: length mismatch")
  }
  if n < 1 || (n & (n - 1)) != 0 {
    raise @core.OwlError::InvalidArgument(
      "ifft: length must be a power of two, got \{n}",
    )
  }
  let re : Array[Double] = []
  let im : Array[Double] = []
  for i in 0..<n {
    re.push(re_part.data[i])
    im.push(im_part.data[i])
  }
  _fft_inplace(re, im, true)
  of_array(re, [n])
}

///|
/// 就地 radix-2 迭代 FFT（forward: inverse=false，inverse=true 时含 1/n 归一化）。
fn _fft_inplace(re : Array[Double], im : Array[Double], inverse : Bool) -> Unit {
  let n = re.length()
  // 位反转置换
  let mut j = 0
  for i in 0..<(n - 1) {
    if i < j {
      let tr = re[i]
      re[i] = re[j]
      re[j] = tr
      let ti = im[i]
      im[i] = im[j]
      im[j] = ti
    }
    let mut m = n >> 1
    while (j & m) != 0 {
      j = j ^ m
      m = m >> 1
    }
    j = j | m
  }
  // 蝶形运算
  let mut len = 2
  let dir = if inverse { 2.0 } else { -2.0 }
  while len <= n {
    let ang = dir * @core.pi / len.to_double()
    let wr0 = @math.cos(ang)
    let wi0 = @math.sin(ang)
    let half = len / 2
    let mut start = 0
    while start < n {
      let mut wr = 1.0
      let mut wi = 0.0
      for k in 0..<half {
        let a = start + k
        let b = a + half
        let vr = re[b] * wr - im[b] * wi
        let vi = re[b] * wi + im[b] * wr
        re[b] = re[a] - vr
        im[b] = im[a] - vi
        re[a] = re[a] + vr
        im[a] = im[a] + vi
        let nwr = wr * wr0 - wi * wi0
        let nwi = wr * wi0 + wi * wr0
        wr = nwr
        wi = nwi
      }
      start = start + len
    }
    len = len * 2
  }
  if inverse {
    let scale = 1.0 / n.to_double()
    for i in 0..<n {
      re[i] = re[i] * scale
      im[i] = im[i] * scale
    }
  }
}
