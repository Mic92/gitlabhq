require 'spec_helper'

describe SlackService::PushMessage do
  subject { SlackService::PushMessage.new(args) }

  let(:args) {
    {
      after: 'after',
      before: 'before',
      project_name: 'project_name',
      ref: 'refs/heads/master',
      user_name: 'user_name',
      project_url: 'url'
    }
  }

  let(:color) { '#345' }

  context 'push' do
    before do
      args[:commits] = [
        { message: 'message1', url: 'url1', id: 'abcdefghijkl', author: { name: 'author1' } },
        { message: 'message2', url: 'url2', id: '123456789012', author: { name: 'author2' } },
      ]
    end

    it 'returns a message regarding pushes' do
      expect(subject.pretext).to eq(
        'user_name pushed to branch <url/commits/master|master> of '\
        '<url|project_name> (<url/compare/before...after|Compare changes>)'
      )
      expect(subject.attachments).to eq([
        {
          text: "<url1|abcdefgh>: message1 - author1\n"\
                "<url2|12345678>: message2 - author2",
          color: color,
        }
      ])
    end
  end

  context 'new branch' do
    before do
      args[:before] = '000000'
    end

    it 'returns a message regarding a new branch' do
      expect(subject.pretext).to eq(
        'user_name pushed new branch <url/commits/master|master> to '\
        '<url|project_name>'
      )
      expect(subject.attachments).to be_empty
    end
  end

  context 'removed branch' do
    before do
      args[:after] = '000000'
    end

    it 'returns a message regarding a removed branch' do
      expect(subject.pretext).to eq(
        'user_name removed branch master from <url|project_name>'
      )
      expect(subject.attachments).to be_empty
    end
  end
end
