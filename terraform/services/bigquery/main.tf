#########################################
# BigQuery datasets
#########################################

resource "google_bigquery_dataset" "raw" {
  dataset_id = "01_raw"
  location   = var.multi_region
  default_table_expiration_ms = null
  delete_contents_on_destroy  = false
}

resource "google_bigquery_dataset" "stage" {
  dataset_id = "02_stage"
  location   = var.multi_region
  default_table_expiration_ms = null
  delete_contents_on_destroy  = false
}

resource "google_bigquery_dataset" "final" {
  dataset_id = "03_final"
  location   = var.multi_region
  default_table_expiration_ms = null
  delete_contents_on_destroy  = false
}
