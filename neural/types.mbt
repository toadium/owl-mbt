///|
/// Weight initialization strategies.
pub enum InitTyp {
  Uniform(Double, Double)
  Gaussian(Double, Double)
  Standard
  Tanh
  GlorotNormal
  GlorotUniform
  LecunNormal
  HeNormal
}

///|
/// Activation function types.
pub enum ActivationTyp {
  Elu
  Relu
  Sigmoid
  HardSigmoid
  Softmax(Int32)
  Softplus
  Softsign
  Tanh
  Relu6
  LeakyRelu(Double)
  TRelu(Double)
  None
}

///|
/// Input layer state.
pub struct InputNeuron {
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Linear layer state.
pub struct LinearNeuron {
  w : Ref[@algodiff.T]
  b : Ref[@algodiff.T]
  init_typ : Ref[InitTyp]
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Linear no bias layer state.
pub struct LinearNoBiasNeuron {
  w : Ref[@algodiff.T]
  init_typ : Ref[InitTyp]
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Activation layer state.
pub struct ActivationNeuron {
  activation : ActivationTyp
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Flatten layer state.
pub struct FlattenNeuron {
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Reshape layer state.
pub struct ReshapeNeuron {
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Dropout layer state.
pub struct DropoutNeuron {
  rate : Double
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Add layer state (multi-input element-wise add).
pub struct AddNeuron {
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Concatenate layer state.
pub struct ConcatenateNeuron {
  axis : Int32
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Lambda layer state (custom function).
pub struct LambdaNeuron {
  lambda : (@algodiff.T) -> @algodiff.T raise
  in_shape : Ref[Array[Int32]]
  out_shape : Ref[Array[Int32]]
}

///|
/// Neuron variant type wrapping all layer types.
#warnings("-unused_constructor")
pub enum Neuron {
  Input(InputNeuron)
  Linear(LinearNeuron)
  LinearNoBias(LinearNoBiasNeuron)
  Activation(ActivationNeuron)
  Flatten(FlattenNeuron)
  Reshape(ReshapeNeuron)
  Dropout(DropoutNeuron)
  Add(AddNeuron)
  Concatenate(ConcatenateNeuron)
  Lambda(LambdaNeuron)
}

///|
/// 创建标准均匀初始化策略（[-1/√fan_in, 1/√fan_in]）。
pub fn init_standard() -> InitTyp {
  Standard
}

///|
/// 创建 Glorot 均匀初始化策略。
pub fn init_glorot_uniform() -> InitTyp {
  GlorotUniform
}

///|
/// 创建 Glorot 正态初始化策略。
pub fn init_glorot_normal() -> InitTyp {
  GlorotNormal
}

///|
/// 创建 Tanh 初始化策略。
pub fn init_tanh() -> InitTyp {
  Tanh
}

///|
/// 创建 Lecun 正态初始化策略。
pub fn init_lecun_normal() -> InitTyp {
  LecunNormal
}

///|
/// 创建 He 正态初始化策略。
pub fn init_he_normal() -> InitTyp {
  HeNormal
}

///|
/// 创建自定义区间 [a, b] 均匀初始化策略。
pub fn init_uniform(a : Double, b : Double) -> InitTyp {
  Uniform(a, b)
}

///|
/// 创建自定义均值/标准差正态初始化策略。
pub fn init_gaussian(mu : Double, sigma : Double) -> InitTyp {
  Gaussian(mu, sigma)
}

///|
/// 创建 ReLU 激活函数。
pub fn act_relu() -> ActivationTyp {
  Relu
}

///|
/// 创建 Sigmoid 激活函数。
pub fn act_sigmoid() -> ActivationTyp {
  Sigmoid
}

///|
/// 创建 Tanh 激活函数。
pub fn act_tanh() -> ActivationTyp {
  Tanh
}

///|
/// 创建恒等激活（无激活函数）。
pub fn act_none() -> ActivationTyp {
  None
}

///|
/// 创建 ELU 激活函数。
pub fn act_elu() -> ActivationTyp {
  Elu
}

///|
/// 创建 Hard Sigmoid 激活函数。
pub fn act_hard_sigmoid() -> ActivationTyp {
  HardSigmoid
}

///|
/// 创建 Softmax 激活函数（沿指定轴归一）。
pub fn act_softmax(axis : Int32) -> ActivationTyp {
  Softmax(axis)
}

///|
/// 创建 Softplus 激活函数。
pub fn act_softplus() -> ActivationTyp {
  Softplus
}

///|
/// 创建 Softsign 激活函数。
pub fn act_softsign() -> ActivationTyp {
  Softsign
}

///|
/// 创建 ReLU6 激活函数（上限 6）。
pub fn act_relu6() -> ActivationTyp {
  Relu6
}

///|
/// 创建 Leaky ReLU 激活函数（负半轴斜率 a）。
pub fn act_leaky_relu(a : Double) -> ActivationTyp {
  LeakyRelu(a)
}

///|
/// 创建阈值化 ReLU 激活函数（阈值 a）。
pub fn act_trelu(a : Double) -> ActivationTyp {
  TRelu(a)
}

///|
/// 将输入层状态包装为网络节点类型。
pub fn neuron_input(n : InputNeuron) -> Neuron {
  Input(n)
}

///|
/// 将线性层状态包装为网络节点类型。
pub fn neuron_linear(n : LinearNeuron) -> Neuron {
  Linear(n)
}
