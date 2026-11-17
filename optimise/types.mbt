///|
/// Learning rate update strategies.
pub enum LearningRate {
  Adagrad(Double)
  Const(Double)
  Decay(Double, Double)
  ExpDecay(Double, Double)
  RMSprop(Double, Double)
  Adam(Double, Double, Double)
  Schedule(Array[Double])
}

///|
/// Batch types.
#warnings("-unused_constructor")
pub enum Batch {
  Full
  Mini(Int32)
  Sample(Int32)
  Stochastic
}

///|
/// Gradient methods.
#warnings("-unused_constructor")
pub enum GradientMethod {
  GD
  CG
  CD
  NonlinearCG
  DaiYuanCG
  NewtonCG
  Newton
}

///|
/// Momentum strategies.
pub enum Momentum {
  Standard(Double)
  Nesterov(Double)
  None
}

///|
/// Regularisation types.
pub enum Regularisation {
  L1norm(Double)
  L2norm(Double)
  ElasticNet(Double, Double)
  None
}

///|
/// Clipping types.
pub enum Clipping {
  L2norm(Double)
  Value(Double, Double)
  None
}

///|
/// Stopping criteria.
pub enum Stopping {
  Const(Double)
  Early(Int32, Int32)
  None
}

///|
/// Optimization state.
pub struct State {
  mut current_batch : Int32
  batches_per_epoch : Int32
  epochs : Double
  batches : Int32
  loss : Array[@algodiff.T]
  start_at : Double
  mut stop : Bool
  mut gs : Array[Array[@algodiff.T]]
  mut ps : Array[Array[@algodiff.T]]
  mut us : Array[Array[@algodiff.T]]
  mut ch : Array[Array[Array[@algodiff.T]]]
}

///|
/// Initialize state.
pub fn init_state(batches_per_epoch : Int32, epochs : Double) -> State {
  let total_batches = (batches_per_epoch.to_double() * epochs).to_int()
  {
    current_batch: 0,
    batches_per_epoch,
    epochs,
    batches: total_batches,
    loss: Array::make(total_batches + 1, @algodiff.pack_flt(0.0)),
    start_at: 0.0,
    stop: false,
    gs: [],
    ps: [],
    us: [],
    ch: [],
  }
}

///|
/// Optimization parameters.
pub struct Params {
  mut epochs : Double
  batch : Batch
  gradient : GradientMethod
  mut learning_rate : LearningRate
  regularisation : Regularisation
  momentum : Momentum
  clipping : Clipping
  stopping : Stopping
  verbosity : Bool
}

///|
/// Create default params.
pub fn default_params() -> Params {
  {
    epochs: 10.0,
    batch: Batch::Full,
    gradient: GradientMethod::GD,
    learning_rate: LearningRate::Const(0.001),
    regularisation: Regularisation::None,
    momentum: Momentum::None,
    clipping: Clipping::None,
    stopping: Stopping::None,
    verbosity: false,
  }
}

///|
/// 设置训练轮数。
pub fn Params::set_epochs(self : Params, epochs : Double) -> Unit {
  self.epochs = epochs
}

///|
/// 设置学习率策略。
pub fn Params::set_learning_rate(self : Params, lr : LearningRate) -> Unit {
  self.learning_rate = lr
}

///|
/// 创建 Adagrad 自适应学习率策略（a 为初始学习率）。
pub fn lr_adagrad(a : Double) -> LearningRate {
  LearningRate::Adagrad(a)
}

///|
/// 创建常数学习率策略。
pub fn lr_const(a : Double) -> LearningRate {
  LearningRate::Const(a)
}

///|
/// 创建反比衰减学习率策略：lr = a / (1 + k·t)。
pub fn lr_decay(a : Double, k : Double) -> LearningRate {
  LearningRate::Decay(a, k)
}

///|
/// 创建指数衰减学习率策略：lr = a·e^(-k·t)。
pub fn lr_exp_decay(a : Double, k : Double) -> LearningRate {
  LearningRate::ExpDecay(a, k)
}

///|
/// 创建 RMSprop 学习率策略（a 为初始学习率，k 为衰减率）。
pub fn lr_rmsprop(a : Double, k : Double) -> LearningRate {
  LearningRate::RMSprop(a, k)
}

///|
/// 创建 Adam 学习率策略（a 为初始学习率，b1/b2 为一阶/二阶矩衰减率）。
pub fn lr_adam(a : Double, b1 : Double, b2 : Double) -> LearningRate {
  LearningRate::Adam(a, b1, b2)
}

///|
/// 创建按预设数表调度的学习率策略。
pub fn lr_schedule(a : Array[Double]) -> LearningRate {
  LearningRate::Schedule(a)
}

///|
/// 创建标准动量策略（m 为动量系数）。
pub fn mom_standard(m : Double) -> Momentum {
  Momentum::Standard(m)
}

///|
/// 创建 Nesterov 动量策略（m 为动量系数）。
pub fn mom_nesterov(m : Double) -> Momentum {
  Momentum::Nesterov(m)
}

///|
/// 创建无动量策略。
pub fn mom_none() -> Momentum {
  Momentum::None
}

///|
/// 创建 L1 正则化（系数 a）。
pub fn reg_l1norm(a : Double) -> Regularisation {
  Regularisation::L1norm(a)
}

///|
/// 创建 L2 正则化（系数 a）。
pub fn reg_l2norm(a : Double) -> Regularisation {
  Regularisation::L2norm(a)
}

///|
/// 创建弹性网络正则化（a·L1 + b·L2）。
pub fn reg_elastic_net(a : Double, b : Double) -> Regularisation {
  Regularisation::ElasticNet(a, b)
}

///|
/// 创建无正则化策略。
pub fn reg_none() -> Regularisation {
  Regularisation::None
}

///|
/// 创建 L2 范数梯度裁剪（a 为范数上限）。
pub fn clip_l2norm(a : Double) -> Clipping {
  Clipping::L2norm(a)
}

///|
/// 创建逐值梯度裁剪（区间 [a, b]）。
pub fn clip_value(a : Double, b : Double) -> Clipping {
  Clipping::Value(a, b)
}

///|
/// 创建无梯度裁剪策略。
pub fn clip_none() -> Clipping {
  Clipping::None
}

///|
/// 创建损失阈值停止准则（损失低于 threshold 即停）。
pub fn stop_const(threshold : Double) -> Stopping {
  Stopping::Const(threshold)
}

///|
/// 创建早停准则（min_batches 后连续 patience 批无改进即停）。
pub fn stop_early(i : Int32, j : Int32) -> Stopping {
  Stopping::Early(i, j)
}

///|
/// 创建不停止准则。
pub fn stop_none() -> Stopping {
  Stopping::None
}
