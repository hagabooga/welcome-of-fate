class_name DatabaseTable

var db: Plugins.SQLite
var columns: PoolStringArray
var table_name: String
var primary_key = null
var primary_key_is_string: bool = false


func _init(db: Plugins.SQLite, table_name: String, table_schema: Dictionary, to_search_by = null) -> void:
	self.db = db
	self.table_name = table_name
	self.columns = PoolStringArray(table_schema.keys())
	# print(self.columns)

	for column in table_schema:
		if "primary_key" in table_schema[column]:
			primary_key = column
			primary_key_is_string = table_schema[column].data_type == "text"

	if to_search_by != null:
		primary_key = to_search_by
		if to_search_by is String:
			primary_key_is_string = true

	db.create_table(table_name, table_schema)


func insert(data: Dictionary) -> void:
	db.insert_row(table_name, data)


# Returns {} if no key exists
func select(key, all = false):
	var condition = '%s == "%s"' if primary_key_is_string else "%s == %d"
	var row = db.select_rows(table_name, condition % [primary_key, key], columns)
	if len(row) == 0:
		return {}
	return row if all else row[0]
