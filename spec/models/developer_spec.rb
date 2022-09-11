# frozen_string_literal: true

require 'rails_helper'

describe Developer, type: :model do
  let(:john) { create(:developer, username: 'john') }
  let(:leo) { create(:developer, username: 'leo') }
  let(:william) { create(:developer, username: 'william') }

  it 'add a follower' do
    expect(john.followers.count).to eq(0)
    expect(leo.following.count).to eq(0)

    john.followers << leo

    expect(leo.following).to eq([john])
    expect(john.followers).to eq([leo])
  end
end
