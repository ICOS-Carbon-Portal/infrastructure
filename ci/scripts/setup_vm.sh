apt update -y && apt upgrade -y && apt install -y docker-compose-v2 python3 python-is-python3 python3-venv
python -m venv py_env
source py_env/bin/activate && pip install ansible requests
