# # Bucket
# resource "google_storage_bucket" "static" {
#  name          = "gcs-bucket-${var.env}"
#  location      = var.region
#  storage_class = "STANDARD"
#  uniform_bucket_level_access = true
# }