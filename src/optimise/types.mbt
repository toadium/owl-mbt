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
  Mini(Int)
  Sample(Int)
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
  Early(Int, Int)
  None
}

///|
/// Optimization state.
pub struct State {
  mut current_batch : Int
  batches_per_epoch : Int
  epochs : Double
  batches : Int
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
pub fn init_state(batches_per_epoch : Int, epochs : Double) -> State {
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
pub fn Params::set_epochs(self : Params, epochs : Double) -> Unit {
  self.epochs = epochs
}

///|
pub fn Params::set_learning_rate(self : Params, lr : LearningRate) -> Unit {
  self.learning_rate = lr
}

///|
pub fn lr_adagrad(a : Double) -> LearningRate {
  LearningRate::Adagrad(a)
}

///|
pub fn lr_const(a : Double) -> LearningRate {
  LearningRate::Const(a)
}

///|
pub fn lr_decay(a : Double, k : Double) -> LearningRate {
  LearningRate::Decay(a, k)
}

///|
pub fn lr_exp_decay(a : Double, k : Double) -> LearningRate {
  LearningRate::ExpDecay(a, k)
}

///|
pub fn lr_rmsprop(a : Double, k : Double) -> LearningRate {
  LearningRate::RMSprop(a, k)
}

///|
pub fn lr_adam(a : Double, b1 : Double, b2 : Double) -> LearningRate {
  LearningRate::Adam(a, b1, b2)
}

///|
pub fn lr_schedule(a : Array[Double]) -> LearningRate {
  LearningRate::Schedule(a)
}

///|
pub fn mom_standard(m : Double) -> Momentum {
  Momentum::Standard(m)
}

///|
pub fn mom_nesterov(m : Double) -> Momentum {
  Momentum::Nesterov(m)
}

///|
pub fn mom_none() -> Momentum {
  Momentum::None
}

///|
pub fn reg_l1norm(a : Double) -> Regularisation {
  Regularisation::L1norm(a)
}

///|
pub fn reg_l2norm(a : Double) -> Regularisation {
  Regularisation::L2norm(a)
}

///|
pub fn reg_elastic_net(a : Double, b : Double) -> Regularisation {
  Regularisation::ElasticNet(a, b)
}

///|
pub fn reg_none() -> Regularisation {
  Regularisation::None
}

///|
pub fn clip_l2norm(a : Double) -> Clipping {
  Clipping::L2norm(a)
}

///|
pub fn clip_value(a : Double, b : Double) -> Clipping {
  Clipping::Value(a, b)
}

///|
pub fn clip_none() -> Clipping {
  Clipping::None
}

///|
pub fn stop_const(threshold : Double) -> Stopping {
  Stopping::Const(threshold)
}

///|
pub fn stop_early(i : Int, j : Int) -> Stopping {
  Stopping::Early(i, j)
}

///|
pub fn stop_none() -> Stopping {
  Stopping::None
}
