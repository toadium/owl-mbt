# Warning 检查报告（v1）

## 检查结果

ISSUES_FOUND

## 执行信息

- 命令：`moon check`
- 退出码：0
- Warning总数：236

## Warning统计

| Warning类别 | 问题数 |
|------------|-------|
| unused_constructor | 119 |
| core_package_not_imported | 78 |
| unused_value | 19 |
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

### unused_value

| 文件 | 行号 | Warning内容 |
|------|------|------------|
| src/algodiff/ops_arr_ext.mbt | 93 | Unused variable 'full_slice' |
| src/algodiff/ops_arr_ext.mbt | 112 | Unused variable 'v' |
| src/algodiff/ops_piso.mbt | 123 | Unused variable 'cp' |
| src/algodiff/ops_piso.mbt | 124 | Unused variable 'cp' |
| src/algodiff/ops_piso.mbt | 149 | Unused variable 'cp' |
| src/algodiff/ops_piso_ext.mbt | 21 | Unused variable 'a' |
| src/algodiff/ops_piso_ext.mbt | 22 | Unused variable 'b' |
| src/ndarray/core.mbt | 113 | Unused function 'get_broadcasted_index' |
| src/ndarray/nn_backward.mbt | 181 | Unused variable 'in_channel' |
| src/ndarray/nn_backward.mbt | 414 | Unused variable 'in_channel' |
| src/ndarray/nn_backward.mbt | 1049 | Unused variable 'kernel_cols' |
| src/ndarray/nn_backward.mbt | 1050 | Unused variable 'kernel_rows' |
| src/ndarray/nn_backward.mbt | 1051 | Unused variable 'in_channel' |
| src/ndarray/nn_backward.mbt | 1052 | Unused variable 'out_channel' |
| src/ndarray/nn_conv.mbt | 126 | Unused variable 'k_stride' |
| src/optimise/modules.mbt | 106 | Unused variable 'f' |
| src/optimise/modules.mbt | 107 | Unused variable 'w' |
| src/optimise/modules.mbt | 195 | Unused variable 'a' |
| src/optimise/modules.mbt | 195 | Unused variable 'b' |

### unused_error_type

| 文件 | 行号 | Warning内容 |
|------|------|------------|
| src/algodiff/ops_arr2.mbt | 89 | The error type of this function is never used. |
| src/algodiff/ops_siso.mbt | 38 | The error type of this function is never used. |
| src/algodiff/ops_siso.mbt | 39 | The error type of this function is never used. |
| src/algodiff/ops_siso.mbt | 193 | The error type of this function is never used. |
| src/algodiff/ops_siso.mbt | 194 | The error type of this function is never used. |
| src/algodiff/types.mbt | 193 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 408 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 1034 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 1047 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 1114 | The error type of this function is never used. |
| src/ndarray/nn_backward.mbt | 1127 | The error type of this function is never used. |
| src/ndarray/nn_conv.mbt | 101 | The error type of this function is never used. |
| src/ndarray/nn_conv.mbt | 264 | The error type of this function is never used. |
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
Warning: [0024]
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_arr2.mbt:89:28
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_arr_ext.mbt:93:3
    Warning (unused_value): Unused variable 'full_slice'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_arr_ext.mbt:112:7
    Warning (unused_value): Unused variable 'v'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_piso.mbt:123:8
    Warning (unused_value): Unused variable 'cp'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_piso.mbt:124:14
    Warning (unused_value): Unused variable 'cp'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_piso.mbt:149:8
    Warning (unused_value): Unused variable 'cp'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_piso_ext.mbt:13:5
    Warning (deprecated_syntax): This `fn` may raise error but is not annotated with `raise`, this kind of effect inference is deprecated, use arrow function `(..) => ...` instead or add explicit `raise` annotation.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_piso_ext.mbt:21:8
    Warning (unused_value): Unused variable 'a'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_piso_ext.mbt:22:11
    Warning (unused_value): Unused variable 'b'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_siso.mbt:38:20
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_siso.mbt:39:19
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_siso.mbt:193:21
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\ops_siso.mbt:194:20
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\algodiff\types.mbt:193:24
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:48:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:76:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:113:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:138:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:166:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:195:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:202:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:237:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:375:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:388:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:389:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:400:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:401:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:402:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:403:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:405:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:408:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:409:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:412:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:413:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:414:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:416:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:447:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:546:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:552:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:557:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:564:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:566:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:567:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:570:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:572:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:573:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:589:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:591:18
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:592:15
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:599:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:600:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:600:37
    Warning (deprecated): use `x is None` instead
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:606:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:608:18
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:609:15
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:615:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:647:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:653:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:658:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:664:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:669:5
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:677:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:679:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:680:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:684:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:687:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:695:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:697:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:698:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:703:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:705:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:706:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:711:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:715:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:718:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:733:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:734:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:738:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:739:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:749:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:751:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:752:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:757:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:759:16
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\compute_wbtest.mbt:760:13
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:12:3
    Warning (unused_constructor): Variant 'Noop' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:15:3
    Warning (unused_constructor): Variant 'Empty' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:18:3
    Warning (unused_constructor): Variant 'Create' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:19:3
    Warning (unused_constructor): Variant 'Sequential' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:20:3
    Warning (unused_constructor): Variant 'Uniform' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:21:3
    Warning (unused_constructor): Variant 'Gaussian' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:22:3
    Warning (unused_constructor): Variant 'Bernoulli' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:23:3
    Warning (unused_constructor): Variant 'Get' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:24:3
    Warning (unused_constructor): Variant 'Set' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:26:3
    Warning (unused_constructor): Variant 'Reset' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:28:3
    Warning (unused_constructor): Variant 'Reverse' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:29:3
    Warning (unused_constructor): Variant 'Tile' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:30:3
    Warning (unused_constructor): Variant 'Repeat' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:31:3
    Warning (unused_constructor): Variant 'Concatenate' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:32:3
    Warning (unused_constructor): Variant 'Stack' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:33:3
    Warning (unused_constructor): Variant 'Split' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:34:3
    Warning (unused_constructor): Variant 'Draw' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:35:3
    Warning (unused_constructor): Variant 'OneHot' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:38:3
    Warning (unused_constructor): Variant 'Floor' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:39:3
    Warning (unused_constructor): Variant 'Ceil' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:40:3
    Warning (unused_constructor): Variant 'Round' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:42:3
    Warning (unused_constructor): Variant 'Sqrt' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:44:3
    Warning (unused_constructor): Variant 'Log2' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:45:3
    Warning (unused_constructor): Variant 'Log10' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:47:3
    Warning (unused_constructor): Variant 'Sin' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:48:3
    Warning (unused_constructor): Variant 'Cos' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:49:3
    Warning (unused_constructor): Variant 'Tan' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:50:3
    Warning (unused_constructor): Variant 'Sinh' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:51:3
    Warning (unused_constructor): Variant 'Cosh' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:52:3
    Warning (unused_constructor): Variant 'Tanh' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:53:3
    Warning (unused_constructor): Variant 'Asin' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:54:3
    Warning (unused_constructor): Variant 'Acos' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:55:3
    Warning (unused_constructor): Variant 'Atan' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:56:3
    Warning (unused_constructor): Variant 'Asinh' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:57:3
    Warning (unused_constructor): Variant 'Acosh' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:58:3
    Warning (unused_constructor): Variant 'Atanh' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:59:3
    Warning (unused_constructor): Variant 'Min' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:60:3
    Warning (unused_constructor): Variant 'Max' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:62:3
    Warning (unused_constructor): Variant 'SumReduce' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:63:3
    Warning (unused_constructor): Variant 'Signum' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:64:3
    Warning (unused_constructor): Variant 'Sigmoid' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:65:3
    Warning (unused_constructor): Variant 'Relu' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:66:3
    Warning (unused_constructor): Variant 'MinPrime' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:67:3
    Warning (unused_constructor): Variant 'MaxPrime' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:68:3
    Warning (unused_constructor): Variant 'SumPrime' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:69:3
    Warning (unused_constructor): Variant 'LogSumExpPrime' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:70:3
    Warning (unused_constructor): Variant 'LogSumExp' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:71:3
    Warning (unused_constructor): Variant 'L1normPrime' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:72:3
    Warning (unused_constructor): Variant 'L2normPrime' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:73:3
    Warning (unused_constructor): Variant 'L2NormSqrPrime' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:74:3
    Warning (unused_constructor): Variant 'ClipByValue' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:75:3
    Warning (unused_constructor): Variant 'ClipByL2norm' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:76:3
    Warning (unused_constructor): Variant 'Pow' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:77:3
    Warning (unused_constructor): Variant 'ScalarPow' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:78:3
    Warning (unused_constructor): Variant 'PowScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:79:3
    Warning (unused_constructor): Variant 'Atan2' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:80:3
    Warning (unused_constructor): Variant 'ScalarAtan2' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:81:3
    Warning (unused_constructor): Variant 'Atan2Scalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:82:3
    Warning (unused_constructor): Variant 'Hypot' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:83:3
    Warning (unused_constructor): Variant 'Min2' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:84:3
    Warning (unused_constructor): Variant 'Max2' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:86:3
    Warning (unused_constructor): Variant 'Sub' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:88:3
    Warning (unused_constructor): Variant 'Div' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:89:3
    Warning (unused_constructor): Variant 'AddScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:90:3
    Warning (unused_constructor): Variant 'SubScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:91:3
    Warning (unused_constructor): Variant 'MulScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:92:3
    Warning (unused_constructor): Variant 'DivScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:93:3
    Warning (unused_constructor): Variant 'ScalarAdd' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:94:3
    Warning (unused_constructor): Variant 'ScalarSub' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:95:3
    Warning (unused_constructor): Variant 'ScalarMul' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:96:3
    Warning (unused_constructor): Variant 'ScalarDiv' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:97:3
    Warning (unused_constructor): Variant 'FMA' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:98:3
    Warning (unused_constructor): Variant 'EltEqual' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:99:3
    Warning (unused_constructor): Variant 'EltNotEqual' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:100:3
    Warning (unused_constructor): Variant 'EltLess' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:101:3
    Warning (unused_constructor): Variant 'EltGreater' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:102:3
    Warning (unused_constructor): Variant 'EltLessEqual' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:103:3
    Warning (unused_constructor): Variant 'EltGreaterEqual' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:104:3
    Warning (unused_constructor): Variant 'EltEqualScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:105:3
    Warning (unused_constructor): Variant 'EltNotEqualScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:106:3
    Warning (unused_constructor): Variant 'EltLessScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:107:3
    Warning (unused_constructor): Variant 'EltGreaterScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:108:3
    Warning (unused_constructor): Variant 'EltLessEqualScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:109:3
    Warning (unused_constructor): Variant 'EltGreaterEqualScalar' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:110:3
    Warning (unused_constructor): Variant 'Conv1d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:111:3
    Warning (unused_constructor): Variant 'Conv2d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:112:3
    Warning (unused_constructor): Variant 'Conv3d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:113:3
    Warning (unused_constructor): Variant 'TransposeConv1d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:114:3
    Warning (unused_constructor): Variant 'TransposeConv2d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:115:3
    Warning (unused_constructor): Variant 'TransposeConv3d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:116:3
    Warning (unused_constructor): Variant 'MaxPool1d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:117:3
    Warning (unused_constructor): Variant 'MaxPool2d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:118:3
    Warning (unused_constructor): Variant 'MaxPool3d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:119:3
    Warning (unused_constructor): Variant 'AvgPool1d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:120:3
    Warning (unused_constructor): Variant 'AvgPool2d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:121:3
    Warning (unused_constructor): Variant 'AvgPool3d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:122:3
    Warning (unused_constructor): Variant 'UpSampling2d' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:123:3
    Warning (unused_constructor): Variant 'RowNum' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:124:3
    Warning (unused_constructor): Variant 'ColNum' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:125:3
    Warning (unused_constructor): Variant 'Row' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:126:3
    Warning (unused_constructor): Variant 'Rows' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:127:3
    Warning (unused_constructor): Variant 'CopyRowTo' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:128:3
    Warning (unused_constructor): Variant 'CopyColTo' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:130:3
    Warning (unused_constructor): Variant 'Inv' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:131:3
    Warning (unused_constructor): Variant 'Trace' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:133:3
    Warning (unused_constructor): Variant 'ToRows' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:134:3
    Warning (unused_constructor): Variant 'OfRows' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\compute\types.mbt:135:3
    Warning (unused_constructor): Variant 'FusedAdagrad' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\core.mbt:113:4
    Warning (unused_value): Unused function 'get_broadcasted_index'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\ndarray_test.mbt:817:44
    Warning (deprecated): Use `PI` instead
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:181:7
    Warning (unused_value): Unused variable 'in_channel'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:408:14
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:414:7
    Warning (unused_value): Unused variable 'in_channel'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:1034:14
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:1047:14
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:1049:7
    Warning (unused_value): Unused variable 'kernel_cols'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:1050:7
    Warning (unused_value): Unused variable 'kernel_rows'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:1051:7
    Warning (unused_value): Unused variable 'in_channel'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:1052:7
    Warning (unused_value): Unused variable 'out_channel'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:1114:14
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_backward.mbt:1127:14
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_conv.mbt:101:14
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_conv.mbt:126:7
    Warning (unused_value): Unused variable 'k_stride'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\ndarray\nn_conv.mbt:264:14
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\neural\graph.mbt:243:43
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\neural\neural_test.mbt:298:21
    Warning (deprecated_syntax): This `fn` may raise error but is not annotated with `raise`, this kind of effect inference is deprecated, use arrow function `(..) => ...` instead or add explicit `raise` annotation.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\neural\neuron.mbt:95:60
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\neural\types.mbt:120:3
    Warning (unused_constructor): Variant 'Add' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\neural\types.mbt:121:3
    Warning (unused_constructor): Variant 'Concatenate' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\modules.mbt:106:3
    Warning (unused_value): Unused variable 'f'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\modules.mbt:107:3
    Warning (unused_value): Unused variable 'w'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\modules.mbt:192:69
    Warning (unused_error_type): The error type of this function is never used.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\modules.mbt:195:11
    Warning (unused_value): Unused variable 'a'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\modules.mbt:195:14
    Warning (unused_value): Unused variable 'b'
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\optimise_wbtest.mbt:18:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\optimise_wbtest.mbt:30:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\optimise_wbtest.mbt:42:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\optimise_wbtest.mbt:54:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\optimise_wbtest.mbt:66:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\optimise_wbtest.mbt:77:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\optimise_wbtest.mbt:79:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\optimise_wbtest.mbt:88:3
    Warning (core_package_not_imported): Package `test` from `moonbitlang/core/` is used without import. This is deprecated. Please add it to the imports in the moon.pkg file.
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\types.mbt:17:3
    Warning (unused_constructor): Variant 'Mini' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\types.mbt:18:3
    Warning (unused_constructor): Variant 'Sample' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\types.mbt:19:3
    Warning (unused_constructor): Variant 'Stochastic' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\types.mbt:26:3
    Warning (unused_constructor): Variant 'CG' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\types.mbt:27:3
    Warning (unused_constructor): Variant 'CD' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\types.mbt:28:3
    Warning (unused_constructor): Variant 'NonlinearCG' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\types.mbt:29:3
    Warning (unused_constructor): Variant 'DaiYuanCG' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\types.mbt:30:3
    Warning (unused_constructor): Variant 'NewtonCG' is never constructed
  D:\CodeWorkspace\forMoonbit\owl-mbt\src\optimise\types.mbt:31:3
    Warning (unused_constructor): Variant 'Newton' is never constructed
```

## 判定

- **CLEAN**：编译输出中无warning
- **ISSUES_FOUND**：编译输出中存在至少一个warning

当前判定：**ISSUES_FOUND**（检测到 236 个 warning）