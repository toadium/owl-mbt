///|
/// 数学常量。移植自 owl_const.ml 第 11-43 行。
/// OCaml 源用 36 位有效数字，Double 仅 ~15-16 位，截断后与 OCaml float 行为一致。
pub let e : Double = 2.718281828459045235360287471352662498

///|
pub let euler : Double = 0.577215664901532860606512090082402431

///|
pub let log2e : Double = 1.442695040888963407359924681001892137

///|
pub let log10e : Double = 0.434294481903251827651128918916605082

///|
pub let loge2 : Double = 0.693147180559945309417232121458176568

///|
pub let loge10 : Double = 2.302585092994045684017991454684364208

///|
pub let logepi : Double = 1.144729885849400174143427351353058711

///|
pub let sqrt1_2 : Double = 0.707106781186547524400844362104849039

///|
pub let sqrt2 : Double = 1.414213562373095048801688724209698079

///|
pub let sqrt3 : Double = 1.732050807568877293527446341505872366

///|
pub let sqrtpi : Double = 1.772453850905516027298167483341145182

///|
pub let pi : Double = 3.141592653589793238462643383279502884

///|
/// 2*pi (not pi/2 — see pi_2 for pi divided by 2)
pub let pi2 : Double = 6.283185307179586476925286766559005768

///|
/// 4*pi (not pi/4 — see pi_4 for pi divided by 4)
pub let pi4 : Double = 12.56637061435917295385057353311801153

///|
/// pi/2 (not 2*pi — see pi2 for pi multiplied by 2)
pub let pi_2 : Double = 1.570796326794896619231321691639751442

///|
/// pi/4 (not 4*pi — see pi4 for pi multiplied by 4)
pub let pi_4 : Double = 0.785398163397448309615660845819875721

///|
pub let eps : Double = 1.0e-15

///|
pub let max_float64 : Double = 1.7976931348623157e308

///|
pub let min_float64 : Double = -1.7976931348623157e308

///|
/// Minimum positive normal double (DBL_MIN ≈ 2.225e-308)
pub let min_normal64 : Double = 2.2250738585072014e-308
