# Amazon ECS Workshop

This is part of an Amazon ECS workshop at https://ecsworkshop.com

## Config validation

`buildspec.yml` and `mu.yml` are validated by yamllint and a pytest schema suite:

```bash
pip install -r requirements-dev.txt
yamllint -s .
pytest
```
