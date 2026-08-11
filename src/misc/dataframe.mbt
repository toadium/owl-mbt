///|
/// DataFrame column type.
pub enum ColumnType {
  FloatCol
  IntCol
  StringCol
}

///|
/// A column in the DataFrame.
pub struct Column {
  name : String
  typ : ColumnType
  float_data : Array[Double]
  int_data : Array[Int]
  string_data : Array[String]
}

///|
/// DataFrame: a table of named columns.
pub struct DataFrame {
  columns : Array[Column]
  n_rows : Int
}

///|
/// Create a float column.
pub fn float_column(name : String, data : Array[Double]) -> Column {
  { name, typ: FloatCol, float_data: data, int_data: [], string_data: [] }
}

///|
/// Create an int column.
pub fn int_column(name : String, data : Array[Int]) -> Column {
  { name, typ: IntCol, float_data: [], int_data: data, string_data: [] }
}

///|
/// Create a string column.
pub fn string_column(name : String, data : Array[String]) -> Column {
  { name, typ: StringCol, float_data: [], int_data: [], string_data: data }
}

///|
/// Create a DataFrame from columns.
pub fn make_dataframe(columns : Array[Column]) -> DataFrame raise {
  let n_rows = if columns.length() > 0 {
    match columns[0].typ {
      FloatCol => columns[0].float_data.length()
      IntCol => columns[0].int_data.length()
      StringCol => columns[0].string_data.length()
    }
  } else {
    0
  }
  for col in columns {
    let len = match col.typ {
      FloatCol => col.float_data.length()
      IntCol => col.int_data.length()
      StringCol => col.string_data.length()
    }
    if len != n_rows {
      raise @types.OwlError::InvalidArgument(
        "make_dataframe: column length mismatch",
      )
    }
  }
  { columns, n_rows }
}

///|
/// Get the number of rows.
pub fn num_rows(df : DataFrame) -> Int {
  df.n_rows
}

///|
/// Get the number of columns.
pub fn num_cols(df : DataFrame) -> Int {
  df.columns.length()
}

///|
/// Get column names.
pub fn col_names(df : DataFrame) -> Array[String] {
  Array::makei(df.columns.length(), fn(i) { df.columns[i].name })
}

///|
/// Get a column by name.
pub fn get_column(df : DataFrame, name : String) -> Column raise {
  for col in df.columns {
    if col.name == name {
      return col
    }
  }
  raise @types.OwlError::InvalidArgument("get_column: column not found")
}

///|
/// Get float data from a column.
pub fn get_float_data(col : Column) -> Array[Double] {
  col.float_data
}

///|
/// Get int data from a column.
pub fn get_int_data(col : Column) -> Array[Int] {
  col.int_data
}

///|
/// Get string data from a column.
pub fn get_string_data(col : Column) -> Array[String] {
  col.string_data
}

///|
/// Compute the mean of a float column.
pub fn col_mean(df : DataFrame, name : String) -> Double raise {
  let col = get_column(df, name)
  let data = col.float_data
  if data.length() == 0 {
    0.0
  } else {
    let mut sum = 0.0
    for v in data {
      sum = sum + v
    }
    sum / data.length().to_double()
  }
}

///|
/// Compute the sum of a float column.
pub fn col_sum(df : DataFrame, name : String) -> Double raise {
  let col = get_column(df, name)
  let mut sum = 0.0
  for v in col.float_data {
    sum = sum + v
  }
  sum
}

///|
/// Compute the min of a float column.
pub fn col_min(df : DataFrame, name : String) -> Double raise {
  let col = get_column(df, name)
  if col.float_data.length() == 0 {
    0.0
  } else {
    let mut m = col.float_data[0]
    for v in col.float_data {
      if v < m {
        m = v
      }
    }
    m
  }
}

///|
/// Compute the max of a float column.
pub fn col_max(df : DataFrame, name : String) -> Double raise {
  let col = get_column(df, name)
  if col.float_data.length() == 0 {
    0.0
  } else {
    let mut m = col.float_data[0]
    for v in col.float_data {
      if v > m {
        m = v
      }
    }
    m
  }
}

///|
/// Convert the DataFrame to a string representation.
pub fn dataframe_to_string(df : DataFrame) -> String {
  let parts : Array[String] = []
  let names = col_names(df)
  for name in names {
    parts.push("\{name}\t")
  }
  parts.push("\n")
  for i in 0..<df.n_rows {
    for col in df.columns {
      match col.typ {
        FloatCol => parts.push("\{col.float_data[i]}\t")
        IntCol => parts.push("\{col.int_data[i]}\t")
        StringCol => parts.push("\{col.string_data[i]}\t")
      }
    }
    parts.push("\n")
  }
  parts.join("")
}
