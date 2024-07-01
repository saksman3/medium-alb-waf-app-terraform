resource "aws_wafv2_web_acl" "medium_app_alb_waf" {
  name        = "${var.env}-medium-app-alb-web-acl"
  scope       = "REGIONAL" # Use "CLOUDFRONT" for global scope
  description = "Web ACL for medium app ALB"
  default_action {
    allow {}
  }
  custom_response_body {
    content =  jsonencode({
                "error":"Access Blocked, due to request origination Country [IE]"
                 "Status": 403
    })
    key = "Geographic"
    content_type = "APPLICATION_JSON"
  }
    # Define a rate-based rule
  rule {
    name     = "SimulateDDoSAttack"
    priority = 1

    action {
      block {}  # You can change this to "count" for monitoring
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 1000  # Set your desired threshold
      }
    }
        visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "byteMatchRule"
    }
  }
  # Byte Match specific string
  rule {
    name     = "ByteMatchRule"
    priority = 0
    
    action {
      block {
        

      }
    }
    statement {
      byte_match_statement {
        search_string = "admin"
        field_to_match {
          single_header {
            name = "user-agent"
          }
        }
        text_transformation {
          type = "NONE"
          priority = 0
        }
        positional_constraint = "CONTAINS"
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "byteMatchRule"
    }
  }
 #Blocked Countries
  rule {
    name     = "BlockedCountries"
    priority = 2
    action {
      block {
                custom_response {        
                custom_response_body_key = "Geographic"
                response_code = 403
        }
      }
    }
    statement {
      geo_match_statement {
        country_codes = ["IE"]
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "blockedCountries"
    }
  }
#Define a Rate based Rule

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "mediumAppWebACL"
    sampled_requests_enabled   = true
  }
}
# associate web_acl with load balancer
resource "aws_wafv2_web_acl_association" "medium_app_waf_association" {
  resource_arn = aws_lb.medium_app_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.medium_app_alb_waf.arn
}
