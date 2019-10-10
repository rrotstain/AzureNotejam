require 'spec_helper'

describe "NoteController" do

  def pad_data
    {
      "name" => "Pad"
    }
  end

  def note_data
    {
      "name" => "Note",
      "text" => "Note text",
      "pad_id" => "0"
    }
  end

  def user_data
    {
      "email" => "user@example.com",
      "password" => "secure_password",
      "password_confirmation" => "secure_password",
    }
  end

  # How to enable testing sessions?
  # http://snippets.aktagon.com/snippets/332-testing-sessions-with-sinatra-and-rack-test
  # Silly workaround:
  def login_user(user_data)
    user = User.create(user_data)
    post "/signin", {
      "email" => user_data['email'],
      "password" => user_data['password']
    }
    user
  end

  it "requires to be signed in to create a note" do
    post "/notes/create", {
      "note" => note_data,
    }
    last_response.should be_redirect
    follow_redirect!
    last_request.url.should include("/signin")
  end

  it "creates a note successfully" do
    login_user user_data
    post "/notes/create", {
      "note" => note_data
    }

    expect(Note.count).to eq(1)
  end

  it "requires mandatory fields to create a note" do
    login_user user_data
    post "/notes/create", {
      "note" => {
        "name" => "",
        "text" => "",
        "pad_id" => "0"
      }
    }
    last_response.body.should include("Name must not be blank")
    last_response.body.should include("Text must not be blank")
  end

  it "edits a note successfully" do
    user = User.create(user_data)
    note = Note.create({name: "Old name", text: "Text", user: user})
    login_user user_data
    post "/notes/#{note.id}/edit", {
      "note" => note_data
    }
    expect(Note.get(note.id).name).to eq(note_data['name'])
  end

  it "requires mandatory fields to edit a note" do
    user = User.create(user_data)
    note = Note.create({name: "Old name", text: "Text", user: user})
    login_user user_data
    post "/notes/#{note.id}/edit", {
      "note" => {
        "name" => "",
        "text" => "",
        "pad_id" => 0
      }
    }
    last_response.body.should include("Name must not be blank")
    last_response.body.should include("Text must not be blank")
  end

  it "doens't allow to edit a note pad by not an owner" do
    owner = User.create(user_data)
    note = Note.create({name: "Old name", text: "Text", user: owner})

    data = user_data
    data['email'] = 'another_user@example.com'
    another_user = User.create(data)

    login_user data
    post "/notes/#{note.id}/edit", {
      "note" => note_data
    }
    expect(last_response.status).to eq(404)
  end

  it "views a note successfully" do
    user = User.create(user_data)
    note = Note.create({name: "Note", text: "Text", user: user})
    login_user user_data

    get "/notes/#{note.id}"
    expect(last_response.status).to eq(200)
  end

  it "doesn't allow to view a note by not an owner" do
    owner = User.create(user_data)
    note = Note.create({name: "Old name", text: "Text", user: owner})

    data = user_data
    data['email'] = 'another_user@example.com'
    another_user = User.create(data)

    login_user data
    get "/notes/#{note.id}/"
    expect(last_response.status).to eq(404)
  end

  it "deletes pad successfully" do
    user = User.create(user_data)
    note = Note.create({name: "Note", text: "Text", user: user})
    login_user user_data
    post "/notes/#{note.id}/delete"
    expect(Note.count).to eq(0)
  end

  it "doesn't allow to delete pad by not an owner" do
    owner = User.create(user_data)
    note = Note.create({name: "Name", text: "Text", user: owner})

    data = user_data
    data['email'] = 'another_user@example.com'
    another_user = User.create(data)

    login_user data
    post "/notes/#{note.id}/delete"
    expect(last_response.status).to eq(404)
  end

  it "doesn't allow to create a note in another's user pad" do
    owner = User.create(user_data)
    pad = Pad.create({name: "Pad", user: owner})

    data = user_data
    data['email'] = 'another_user@example.com'
    another_user = User.create(data)

    login_user data
    post "/notes/create", {
      "note" => {
        "name" => "Note",
        "text" => "Text",
        "pad_id" => pad.id
      }
    }
    expect(last_response.status).to eq(404)
  end
end



