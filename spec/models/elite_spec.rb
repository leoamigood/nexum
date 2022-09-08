# frozen_string_literal: true

require 'rails_helper'

describe Elite, type: :model do
  let(:john) { create(:elite, username: 'john') }
  let(:leo) { create(:elite, username: 'leo') }
  let(:william) { create(:elite, username: 'william') }

  it 'add a follower' do
    expect(john.followers.count).to eq(0)
    expect(leo.following.count).to eq(0)

    john.followers << leo

    expect(leo.following).to eq([john])
    expect(john.followers).to eq([leo])
  end
end
