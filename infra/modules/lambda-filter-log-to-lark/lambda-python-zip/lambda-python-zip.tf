#Before using this module, prepare py code and requirement.txt in the same folder
resource "null_resource" "install_python_dependencies" {
  provisioner "local-exec" {
    command = <<EOT
      ROOT_PATH=$(pwd);
      echo $pwd
      cd ${var.lambda_function_code_path};
      mkdir -p .packages${var.lambda_python_zip_folder};
      rsync -avr --exclude='*.git*' --exclude='*.zip' --exclude='requirements.txt' --exclude='*.packages' . .packages${var.lambda_python_zip_folder};
      set -e && pip3.11 install -r requirements.txt -t .packages${var.lambda_python_zip_folder} --upgrade;
      cd .packages;
      set -e && zip -r ${var.lambda_python_zip_name}.zip * -x '*.git*' -x '*.zip' -x 'requirements.txt' -x '*.packages';
      cd $ROOT_PATH;
      cp ${var.lambda_function_code_path}/.packages/${var.lambda_python_zip_name}.zip lambda-function-zip/;
      rm -rf ${var.lambda_function_code_path}/.packages
   EOT
  }
  triggers = {
    file_hashes = jsonencode({
      for file in fileset("${var.lambda_function_code_path}/", "**") :
      file => filesha256("${var.lambda_function_code_path}/${file}")
      if file != "${var.lambda_python_zip_name}.zip"
    })
  }
}

data "null_data_source" "wait_for_install" {
  inputs = {
    # This ensures that this data resource will not be evaluated until
    # after the null_resource has been created.
    install_python_dependencies_id = null_resource.install_python_dependencies.id

    # This value gives us something to implicitly depend on
    # in the archive_file below.
    lambda_python_zip_key    = "${var.lambda_python_zip_name}.zip"
    lambda_python_zip_source = "lambda-function-zip/${var.lambda_python_zip_name}.zip"
  }
}
