resource "google_project_iam_binding" "project_editors" {
  project = var.project_id
  role    = "roles/editor"

  members = [
    "user:serhii.puzyrov@gmail.com",
    # Add more users here if needed
  ]
}