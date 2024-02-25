resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "example"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric checks cpu utilization"
  alarm_actions       = []
}

resource "aws_cloudwatch_dashboard" "example" {
  dashboard_name = "example"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ECS", "CPUUtilization" ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "CPUUtilization"
      }
    }
  ]
}
EOF
}