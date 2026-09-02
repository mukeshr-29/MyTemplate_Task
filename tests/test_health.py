def test_health_endpoint(testapp):
    response = testapp.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}