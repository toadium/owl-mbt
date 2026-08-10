# Warning 检查报告（v2）

## 检查结果

ISSUES_FOUND

## 执行信息

- 命令：`moon check`
- 退出码：0
- Warning总数：217

## Warning统计

| Warning类别 | 问题数 |
|------------|-------|
| unused_constructor | 119 |
| core_package_not_imported | 78 |
| unused_error_type | 16 |
| deprecated_syntax | 2 |
| deprecated | 2 |

## Warning清单

### unused_constructor

| 文件 | 行号 | Warning内容 |
|------|------|------------|
| src/compute/types.mbt | 12 | Variant 'Noop' is never constructed |
| src/compute/types.mbt | 15 | Variant 'Empty' is never constructed |
| src/compute/types.mbt | 18 | Variant 'Create' is never constructed |
| src/compute/types.mbt | 19 | Variant 'Sequential' is never constructed |
| src/compute/types.mbt | 20 | Variant 'Uniform' is never constructed |
| src/compute/types.mbt | 21 | Variant 'Gaussian' is never constructed |
| src/compute/types.mbt | 22 | Variant 'Bernoulli' is never constructed |
| src/compute/types.mbt | 23 | Variant 'Get' is never constructed |
| src/compute/types.mbt | 24 | Variant 'Set' is never constructed |
| src/compute/types.mbt | 26 | Variant 'Reset' is never constructed |
| src/compute/types.mbt | 28 | Variant 'Reverse' is never constructed |
| src/compute/types.mbt | 29 | Variant 'Tile' is never constructed |
| src/compute/types.mbt | 30 | Variant 'Repeat' is never constructed |
| src/compute/types.mbt | 31 | Variant 'Concatenate' is never constructed |
| src/compute/types.mbt | 32 | Variant 'Stack' is never constructed |
| src/compute/types.mbt | 33 | Variant 'Split' is never constructed |
| src/compute/types.mbt | 34 | Variant 'Draw' is never constructed |
| src/compute/types.mbt | 35 | Variant 'OneHot' is never constructed |
| src/compute/types.mbt | 38 | Variant 'Floor' is never constructed |
| src/compute/types.mbt | 39 | Variant 'Ceil' is never constructed |
| src/compute/types.mbt | 40 | Variant 'Round' is never constructed |
| src/compute/types.mbt | 42 | Variant 'Sqrt' is never constructed |
| src/compute/types.mbt | 44 | Variant 'Log2' is never constructed |
| src/compute/types.mbt | 45 | Variant 'Log10' is never constructed |
| src/compute/types.mbt | 47 | Variant 'Sin' is never constructed |
| src/compute/types.mbt | 48 | Variant 'Cos' is never constructed |
| src/compute/types.mbt | 49 | Variant 'Tan' is never constructed |
| src/compute/types.mbt | 50 | Variant 'Sinh' is never constructed |
| src/compute/types.mbt | 51 | Variant 'Cosh' is never constructed |
| src/compute/types.mbt | 52 | Variant 'Tanh' is never constructed |
| src/compute/types.mbt | 53 | Variant 'Asin' is never constructed |
| src/compute/types.mbt | 54 | Variant 'Acos' is never constructed |
| src/compute/types.mbt | 55 | Variant 'Atan' is never constructed |
| src/compute/types.mbt | 56 | Variant 'Asinh' is never constructed |
| src/compute/types.mbt | 57 | Variant 'Acosh' is never constructed |
| src/compute/types.mbt | 58 | Variant 'Atanh' is never constructed |
| src/compute/types.mbt | 59 | Variant 'Min' is never constructed |
| src/compute/types.mbt | 60 | Variant 'Max' is never constructed |
| src/compute/types.mbt | 62 | Variant 'SumReduce' is never constructed |
| src/compute/types.mbt | 63 | Variant 'Signum' is never constructed |
| src/compute/types.mbt | 64 | Variant 'Sigmoid' is never constructed |
| src/compute/types.mbt | 65 | Variant 'Relu' is never constructed |
| src/compute/types.mbt | 66 | Variant 'MinPrime' is never constructed |
| src/compute/types.mbt | 67 | Variant 'MaxPrime' is never constructed |
| src/compute/types.mbt | 68 | Variant 'SumPrime' is never constructed |
| src/compute/types.mbt | 69 | Variant 'LogSumExpPrime' is never constructed |
| src/compute/types.mbt | 70 | Variant 'LogSumExp' is never constructed |
| src/compute/types.mbt | 71 | Variant 'L1normPrime' is never constructed |
| src/compute/types.mbt | 72 | Variant 'L2normPrime' is never constructed |
| src/compute/types.mbt | 73 | Variant 'L2NormSqrPrime' is never constructed |
| src/compute/types.mbt | 74 | Variant 'ClipByValue' is never constructed |
| src/compute/types.mbt | 75 | Variant 'ClipByL2norm' is never constructed |
| src/compute/types.mbt | 76 | Variant 'Pow' is never constructed |
| src/compute/types.mbt | 77 | Variant 'ScalarPow' is never constructed |
| src/compute/types.mbt | 78 | Variant 'PowScalar' is never constructed |
| src/compute/types.mbt | 79 | Variant 'Atan2' is never constructed |
| src/compute/types.mbt | 80 | Variant 'ScalarAtan2' is never constructed |
| src/compute/types.mbt | 81 | Variant 'Atan2Scalar' is never constructed |
| src/compute/types.mbt | 82 | Variant 'Hypot' is never constructed |
| src/compute/types.mbt | 83 | Variant 'Min2' is never constructed |
| src/compute/types.mbt | 84 | Variant 'Max2' is never constructed |
| src/compute/types.mbt | 86 | Variant 'Sub' is never constructed |
| src/compute/types.mbt | 88 | Variant 'Div' is never constructed |
| src/compute/types.mbt | 89 | Variant 'AddScalar' is never constructed |
| src/compute/types.mbt | 90 | Variant 'SubScalar' is never constructed |
| src/compute/types.mbt | 91 | Variant 'MulScalar' is never constructed |
| src/compute/types.mbt | 92 | Variant 'DivScalar' is never constructed |
| src/compute/types.mbt | 93 | Variant 'ScalarAdd' is never constructed |
| src/compute/types.mbt | 94 | Variant 'ScalarSub' is never constructed |
| src/compute/types.mbt | 95 | Variant 'ScalarMul' is never constructed |
| src/compute/types.mbt | 96 | Variant 'ScalarDiv' is never constructed |
| src/compute/types.mbt | 97 | Variant 'FMA' is never constructed |
| src/compute/types.mbt | 98 | Variant 'EltEqual' is never constructed |
| src/compute/types.mbt | 99 | Variant 'EltNotEqual' is never constructed |
| src/compute/types.mbt | 100 | Variant 'EltLess' is never constructed |
| src/compute/types.mbt | 101 | Variant 'EltGreater' is never constructed |
| src/compute/types.mbt | 102 | Variant 'EltLessEqual' is never constructed |
| src/compute/types.mbt | 103 | Variant 'EltGreaterEqual' is never constructed |
| src/compute/types.mbt | 104 | Variant 'EltEqualScalar' is never constructed |
| src/compute/types.mbt | 105 | Variant 'EltNotEqualScalar' is never constructed |
| src/compute/types.mbt | 106 | Variant 'EltLessScalar' is never constructed |
| src/compute/types.mbt | 107 | Variant 'EltGreaterScalar' is never constructed |
| src/compute/types.mbt | 108 | Variant 'EltLessEqualScalar' is never constructed |
| src/compute/types.mbt | 109 | Variant 'EltGreaterEqualScalar' is never constructed |
| src/compute/types.mbt | 110 | Variant 'Conv1d' is never constructed |
| src/compute/types.mbt | 111 | Variant 'Conv2d' is never constructed |
| src/compute/types.mbt | 112 | Variant 'Conv3d' is never constructed |
| src/compute/types.mbt | 113 | Variant 'TransposeConv1d' is never constructed |
| src/compute/types.mbt | 114 | Variant 'TransposeConv2d' is never constructed |
| src/compute/types.mbt | 115 | Variant 'TransposeConv3d' is never constructed |
| src/compute/types.mbt | 116 | Variant 'MaxPool1d' is never constructed |
| src/compute/types.mbt | 117 | Variant 'MaxPool2d' is never constructed |
| src/compute/types.mbt | 118 | Variant 'MaxPool3d' is never constructed |
| src/compute/types.mbt | 119 | Variant 'AvgPool1d' is never constructed |
| src/compute/types.mbt | 120 | Variant 'AvgPool2d' is never constructed |
| src/compute/types.mbt | 121 | Variant 'AvgPool3d' is never constructed |
| src/compute/types.mbt | 122 | Variant 'UpSampling2d' is never constructed |
| src/compute/types.mbt | 123 | Variant 'RowNum' is never constructed |
| src/compute/types.mbt | 124 | Variant 'ColNum' is never constructed |
| src/compute/types.mbt | 125 | Variant 'Row' is never constructed |
| src/compute/types.mbt | 126 | Variant 'Rows' is never constructed |
| src/compute/types.mbt | 127 | Variant 'CopyRowTo' is never constructed |
| src/compute/types.mbt | 128 | Variant 'CopyColTo' is never constructed |
| src/compute/types.mbt | 130 | Variant 'Inv' is never constructed |
| src/compute/types.mbt | 131 | Variant 'Trace' is never constructed |
| src/compute/types.mbt | 133 | Variant 'ToRows' is never constructed |
| src/compute/types.mbt | 134 | Variant 'OfRows' is never constructed |
| src/compute/types.mbt | 135 | Variant 'FusedAdagrad' is never constructed |
| src/neural/types.mbt | 120 | Variant 'Add' is never constructed |
| src/neural/types.mbt | 121 | Variant 'Concatenate' is never constructed |
| src/optimise/types.mbt | 17 | Variant 'Mini' is never constructed |
| src/optimise/types.mbt | 18 | Variant 'Sample' is never constructed |
| src/optimise/types.mbt | 19 | Variant 'Stochastic' is never constructed |
| src/optimise/types.mbt | 26 | Variant 'CG' is never constructed |
| src/optimise/types.mbt | 27 | Variant 'CD' is never constructed |
| src/optimise/types.mbt | 28 | Variant 'NonlinearCG' is never constructed |
| src/optimise/types.mbt | 29 | Variant 'DaiYuanCG' is never constructed |
| src/optimise/types.mbt | 30 | Variant 'NewtonCG' is never constructed |
| src/optimise/types.mbt | 31 | Variant 'Newton' is never constructed |

### core_package_not_imported

| 文件 | 行号 | Warning内容 |
|------|------|------------|
| src/compute/compute_wbtest.mbt | 48 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 76 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 113 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 138 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 166 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 195 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 202 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 237 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 375 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 388 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 389 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 400 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 401 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 402 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 403 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 405 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 408 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 409 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 412 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 413 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 414 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 416 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 447 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 546 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 552 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 557 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 564 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 566 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 567 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 570 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 572 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 573 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 589 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 591 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 592 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 599 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 600 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 606 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 608 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 609 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 615 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 647 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 653 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 658 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 664 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 669 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 677 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 679 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 680 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 684 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 687 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 695 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 697 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 698 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 703 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 705 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 706 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 711 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 715 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 718 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 733 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 734 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 738 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 739 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 749 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 751 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 752 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 757 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 759 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/compute/compute_wbtest.mbt | 760 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/optimise/optimise_wbtest.mbt | 18 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/optimise/optimise_wbtest.mbt | 30 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/optimise/optimise_wbtest.mbt | 42 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/optimise/optimise_wbtest.mbt | 54 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/optimise/optimise_wbtest.mbt | 66 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/optimise/optimise_wbtest.mbt | 77 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/optimise/optimise_wbtest.mbt | 79 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |
| src/optimise/optimise_wbtest.mbt | 88 | Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file. |

### unused_error_type

| 文件 | 行号 | Warning内容 |
|------|------|------------|
| src/algodiff/ops_arr2.mbt | 89 | The error type of this function is never used. |
| src/algodiff/ops_siso.mbt | 38 | The error type of this function is never used. |
| src/algodiff/ops_siso.mbt | 39 | The error type of this function is never used. |
| src/algodiff/ops_siso.mbt | 193 | The error type of this function is never used. |
| src/algodiff/ops_siso.mbt | 194 | The error type of this function is never used. |
| src/algodiff/types.mbt | 193 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 407 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 1032 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 1045 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 1107 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 1120 | The error type of this function is never used. |
| src/ndarray/nn_conv.mbt | 101 | The error type of this function is never used. |
| src/ndarray/nn_conv.mbt | 263 | The error type of this function is never used. |
| src/neural/graph.mbt | 243 | The error type of this function is never used. |
| src/neural/neuron.mbt | 95 | The error type of this function is never used. |
| src/optimise/modules.mbt | 192 | The error type of this function is never used. |

### deprecated_syntax

| 文件 | 行号 | Warning内容 |
|------|------|------------|
| src/algodiff/ops_piso_ext.mbt | 13 | This `fn` may raise error but is not annotated with `raise`, this kind of effect inference is deprecated, use arrow function `(..) => ...` instead or add explicit `raise` annotation. |
| src/neural/neural_test.mbt | 298 | This `fn` may raise error but is not annotated with `raise`, this kind of effect inference is deprecated, use arrow function `(..) => ...` instead or add explicit `raise` annotation. |

### deprecated

| 文件 | 行号 | Warning内容 |
|------|------|------------|
| src/compute/compute_wbtest.mbt | 600 | use `x is None` instead |
| src/ndarray/ndarray_test.mbt | 817 | Use `PI` instead |

## 原始输出

```
（完整 warning 原始输出见同目录下 raw_output_v2.txt，共 217 条 warning）
```

## 判定

- **ISSUES_FOUND**：编译输出中存在至少一个warning
