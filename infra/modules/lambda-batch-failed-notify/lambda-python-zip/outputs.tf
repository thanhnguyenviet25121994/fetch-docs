#modules/lambda-python-zip/outputs.tf

# output "output_path" {
#   value = data.archive_file.lambda_python_zip.output_path
# }

# output "output_base64sha256" {
#   value = data.archive_file.lambda_python_zip.output_base64sha256
# }

output "lambda_python_zip_key" {
  value = data.null_data_source.wait_for_install.outputs.lambda_python_zip_key
}

output "lambda_python_zip_source" {
  value = data.null_data_source.wait_for_install.outputs.lambda_python_zip_source
}

output "lambda_python_zip_name" {
  value = var.lambda_python_zip_name
}
