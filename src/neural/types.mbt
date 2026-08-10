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
  Softmax(Int)
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
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
}

///|
/// Linear layer state.
pub struct LinearNeuron {
  w : Ref[@algodiff.T]
  b : Ref[@algodiff.T]
  init_typ : Ref[InitTyp]
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
}

///|
/// Linear no bias layer state.
pub struct LinearNoBiasNeuron {
  w : Ref[@algodiff.T]
  init_typ : Ref[InitTyp]
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
}

///|
/// Activation layer state.
pub struct ActivationNeuron {
  activation : ActivationTyp
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
}

///|
/// Flatten layer state.
pub struct FlattenNeuron {
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
}

///|
/// Reshape layer state.
pub struct ReshapeNeuron {
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
}

///|
/// Dropout layer state.
pub struct DropoutNeuron {
  rate : Double
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
}

///|
/// Add layer state (multi-input element-wise add).
pub struct AddNeuron {
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
}

///|
/// Concatenate layer state.
pub struct ConcatenateNeuron {
  axis : Int
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
}

///|
/// Lambda layer state (custom function).
pub struct LambdaNeuron {
  lambda : (@algodiff.T) -> @algodiff.T raise
  in_shape : Ref[Array[Int]]
  out_shape : Ref[Array[Int]]
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
pub fn init_standard() -> InitTyp {
  Standard
}

///|
pub fn init_glorot_uniform() -> InitTyp {
  GlorotUniform
}

///|
pub fn init_glorot_normal() -> InitTyp {
  GlorotNormal
}

///|
pub fn init_tanh() -> InitTyp {
  Tanh
}

///|
pub fn init_lecun_normal() -> InitTyp {
  LecunNormal
}

///|
pub fn init_he_normal() -> InitTyp {
  HeNormal
}

///|
pub fn init_uniform(a : Double, b : Double) -> InitTyp {
  Uniform(a, b)
}

///|
pub fn init_gaussian(mu : Double, sigma : Double) -> InitTyp {
  Gaussian(mu, sigma)
}

///|
pub fn act_relu() -> ActivationTyp {
  Relu
}

///|
pub fn act_sigmoid() -> ActivationTyp {
  Sigmoid
}

///|
pub fn act_tanh() -> ActivationTyp {
  Tanh
}

///|
pub fn act_none() -> ActivationTyp {
  None
}

///|
pub fn act_elu() -> ActivationTyp {
  Elu
}

///|
pub fn act_hard_sigmoid() -> ActivationTyp {
  HardSigmoid
}

///|
pub fn act_softmax(axis : Int) -> ActivationTyp {
  Softmax(axis)
}

///|
pub fn act_softplus() -> ActivationTyp {
  Softplus
}

///|
pub fn act_softsign() -> ActivationTyp {
  Softsign
}

///|
pub fn act_relu6() -> ActivationTyp {
  Relu6
}

///|
pub fn act_leaky_relu(a : Double) -> ActivationTyp {
  LeakyRelu(a)
}

///|
pub fn act_trelu(a : Double) -> ActivationTyp {
  TRelu(a)
}

///|
pub fn neuron_input(n : InputNeuron) -> Neuron {
  Input(n)
}

///|
pub fn neuron_linear(n : LinearNeuron) -> Neuron {
  Linear(n)
}
