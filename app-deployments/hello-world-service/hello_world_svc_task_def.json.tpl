[
  {
    "name": "hello-world-svc",
    "essential": true,
    "memory": 512,
    "cpu": 256,
    "ipc_mode": "task",
    "pid_mode": "task",
    "image": "docker.io/cdempsey1221/hello-service:0.0.1-SNAPSHOT",
    "portMappings": [
        {
            "containerPort": 8091,
            "hostPort": 8091
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/hello-world-svc",
            "awslogs-region": "us-east-2",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "environment": []
  }
]
