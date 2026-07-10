import numpy as np

sql_db_instance_specs = {
    # # t3 - burstable
    # "db.t3.micro": {"vcpu": 2, "memory_gib": 1},
    # "db.t3.small": {"vcpu": 2, "memory_gib": 2},
    # "db.t3.medium": {"vcpu": 2, "memory_gib": 4},
    # "db.t3.large": {"vcpu": 2, "memory_gib": 8},
    # "db.t3.xlarge": {"vcpu": 4, "memory_gib": 16},
    # "db.t3.2xlarge": {"vcpu": 8, "memory_gib": 32},
    # m7i - General purpose
    "db.m7i.large": {"vcpu": 2, "memory_gib": 8},
    "db.m7i.xlarge": {"vcpu": 4, "memory_gib": 16},
    "db.m7i.2xlarge": {"vcpu": 8, "memory_gib": 32},
    "db.m7i.4xlarge": {"vcpu": 16, "memory_gib": 64},
    "db.m7i.8xlarge": {"vcpu": 32, "memory_gib": 128},
    "db.m7i.12xlarge": {"vcpu": 48, "memory_gib": 192},
    "db.m7i.16xlarge": {"vcpu": 64, "memory_gib": 256},
    "db.m7i.24xlarge": {"vcpu": 96, "memory_gib": 384},
    "db.m7i.48xlarge": {"vcpu": 192, "memory_gib": 768},
    # r6i - Memory optimised
    "db.r6i.large": {"vcpu": 2, "memory_gib": 16},
    "db.r6i.xlarge": {"vcpu": 4, "memory_gib": 32},
    "db.r6i.2xlarge": {"vcpu": 8, "memory_gib": 64},
    "db.r6i.4xlarge": {"vcpu": 16, "memory_gib": 128},
    "db.r6i.8xlarge": {"vcpu": 32, "memory_gib": 256},
    "db.r6i.12xlarge": {"vcpu": 48, "memory_gib": 384},
    "db.r6i.16xlarge": {"vcpu": 64, "memory_gib": 512},
    "db.r6i.24xlarge": {"vcpu": 96, "memory_gib": 768},
    "db.r6i.32xlarge": {"vcpu": 128, "memory_gib": 1024}
}

reverse_index = {
    (attrs["vcpu"], attrs["memory_gib"]): db_type
    for db_type, attrs in sql_db_instance_specs.items()
}

db_type = reverse_index.get((8, 64))

print(db_type)