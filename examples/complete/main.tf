################################################################################
# CDN Module Configuration
################################################################################

module "cdn" {
  source                = "git::https://github.com/surangajayalath/terraform-aws-cdn-with-codepipeline"
  account_id            = "12345678901234"
  region                = "us-east-1"
  branch_name           = "main"
  root_object_name      = "index.html"
  cdn_name              = "devops-app-cdn"
  domain_name           = "devops.app.example.com"
  source_bucket_name    = "devops-app-build-files-us-east-1"
  pipeline_name         = "devops-app-cdn-deployment-pipeline"
  pipeline_bucket_name  = "devops-app-cdn-deployment-pipeline-artifact-us-east-1"
  source_connection_arn = "arn:aws:codeconnections:us-east-1:12345678901234:connection/dafc488c-8fc5-3159d072f3-cb86-bdfsdgd"
  github_repo           = "{github-username}/{source-file-repo-name}"
  zone_id               = aws_route53_zone.primary.zone_id
  buildspec_file_name   = "buildspec.yml"
  tags                  = { environment = "dev" }
  providers = {
    aws = aws.secondary
  }
}