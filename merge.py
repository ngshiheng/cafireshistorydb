import sqlite3


def merge_databases(source_db_path, target_db_path, table_name):
    source_conn = sqlite3.connect(source_db_path)
    target_conn = sqlite3.connect(target_db_path)

    source_cursor = source_conn.cursor()
    target_cursor = target_conn.cursor()

    source_cursor.execute(f"SELECT * FROM {table_name}")
    source_records = source_cursor.fetchall()

    for record in source_records:
        unique_id = record[0]
        target_cursor.execute(
            f"SELECT 1 FROM {table_name} WHERE UniqueId=?", (unique_id,)
        )
        exists = target_cursor.fetchone()

        if exists:
            continue

        target_cursor.execute(
            f"INSERT INTO {table_name} VALUES ({','.join(['?']*len(record))})",
            record,
        )

    target_conn.commit()
    target_conn.close()
    source_conn.close()


if __name__ == "__main__":
    merge_databases("fires.db", "data/fires.db", "incidents")
