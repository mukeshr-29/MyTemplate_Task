from playwright.sync_api import Page, expect


def test_user_can_navigate_to_signup(page: Page):
    page.goto("http://127.0.0.1:5000/")

    expect(page).to_have_title("MyTemplate")

    page.get_by_role("link", name="Demo").first.click()

    expect(page).to_have_url("http://127.0.0.1:5000/signup")