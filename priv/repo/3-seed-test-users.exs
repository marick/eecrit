Code.load_file "priv/repo/util.exs"
alias Eecrit.U

U.add_user! display_name: "Test User 1", login_name: "1@critter4us.com", password: "password"
U.put_user_in_org!("1@critter4us.com", "test org", "admin")

U.add_user! display_name: "Test User 2", login_name: "2@critter4us.com", password: "password"
U.put_user_in_org!("2@critter4us.com", "test org", "admin")
