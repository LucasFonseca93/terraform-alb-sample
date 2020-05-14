{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:PutObject"
        ],
        "Effect": "Allow",
        "Resource": "${s3_arn}",
        "Principal": {
          "AWS": [
            "${aws_acc}"
          ]
        }
      }
    ]
  }