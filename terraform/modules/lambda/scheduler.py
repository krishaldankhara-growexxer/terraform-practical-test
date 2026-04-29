import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

REGION = os.environ.get("AWS_REGION", "ap-south-1")
ACTION = os.environ.get("ACTION", "stop")
TAG_KEY = os.environ.get("TAG_KEY", "AutoSchedule")
TAG_VALUE = os.environ.get("TAG_VALUE", "true")


def get_tagged_ec2_instances(ec2):
    paginator = ec2.get_paginator("describe_instances")
    pages = paginator.paginate(
        Filters=[
            {"Name": f"tag:{TAG_KEY}", "Values": [TAG_VALUE]},
            {"Name": "instance-state-name",
             "Values": ["running"] if ACTION == "stop" else ["stopped"]}
        ]
    )
    ids = []
    for page in pages:
        for reservation in page["Reservations"]:
            for instance in reservation["Instances"]:
                ids.append(instance["InstanceId"])
    return ids


def get_tagged_rds_instances(rds):
    paginator = rds.get_paginator("describe_db_instances")
    pages = paginator.paginate()
    ids = []
    for page in pages:
        for db in page["DBInstances"]:
            arn = db["DBInstanceArn"]
            db_id = db["DBInstanceIdentifier"]
            db_status = db["DBInstanceStatus"]

            tags_resp = rds.list_tags_for_resource(ResourceName=arn)
            tag_map = {t["Key"]: t["Value"] for t in tags_resp["TagList"]}

            if tag_map.get(TAG_KEY) == TAG_VALUE:
                if ACTION == "stop" and db_status == "available":
                    ids.append(db_id)
                elif ACTION == "start" and db_status == "stopped":
                    ids.append(db_id)
    return ids


def lambda_handler(_event, _context):
    ec2 = boto3.client("ec2", region_name=REGION)
    rds = boto3.client("rds", region_name=REGION)

    logger.info("Scheduler triggered — ACTION=%s", ACTION)

    ec2_ids = get_tagged_ec2_instances(ec2)
    if ec2_ids:
        if ACTION == "stop":
            ec2.stop_instances(InstanceIds=ec2_ids)
            logger.info("Stopped EC2 instances: %s", ec2_ids)
        else:
            ec2.start_instances(InstanceIds=ec2_ids)
            logger.info("Started EC2 instances: %s", ec2_ids)
    else:
        logger.info("No eligible EC2 instances found.")

    rds_ids = get_tagged_rds_instances(rds)
    if rds_ids:
        for db_id in rds_ids:
            if ACTION == "stop":
                rds.stop_db_instance(DBInstanceIdentifier=db_id)
                logger.info("Stopped RDS: %s", db_id)
            else:
                rds.start_db_instance(DBInstanceIdentifier=db_id)
                logger.info("Started RDS: %s", db_id)
    else:
        logger.info("No eligible RDS instances found.")

    return {
        "status": "success",
        "action": ACTION,
        "ec2_instances": ec2_ids,
        "rds_instances": rds_ids
    }
