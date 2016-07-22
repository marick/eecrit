Code.load_file "priv/repo/util.exs"
alias Eecrit.U

U.add_user! display_name: "Test Superuser", login_name: "root@critter4us.com", password: "password"
U.put_user_in_org!("root@critter4us.com", "test org", "superuser")

U.add_user! display_name: "Test Admin", login_name: "admin@critter4us.com", password: "password"
U.put_user_in_org!("admin@critter4us.com", "test org", "admin")

U.add_user! display_name: "Test User", login_name: "user@critter4us.com", password: "password"
U.put_user_in_org!("user@critter4us.com", "test org", "user")
