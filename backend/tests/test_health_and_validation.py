from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health_endpoint_returns_healthy_status():
    response = client.get('/health')

    assert response.status_code == 200
    assert response.json()['status'] == 'ok'


def test_version_endpoint_returns_application_version():
    response = client.get('/version')

    assert response.status_code == 200
    assert 'version' in response.json()


def test_analyze_rejects_invalid_file_type():
    response = client.post(
        '/api/analyze',
        files={'file': ('resume.txt', b'not a real resume', 'text/plain')},
    )

    assert response.status_code == 400
    assert response.json()['error'] == 'invalid_file_type'
