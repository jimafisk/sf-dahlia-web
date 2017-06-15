require 'rails_helper'

# lifted from https://gist.github.com/ChuckJHardy/10f54fc567ba3bd4d6f1
RSpec.describe ShortFormAttachmentJob, type: :job do
  include ActiveJob::TestHelper

  let(:file) { create(:uploaded_file) }
  let(:opts) do
    {
      application_id: 'a1',
      application_member_id: 'b2',
      application_preference_id: 'c3',
      file_id: file.id,
    }
  end

  subject(:job) { described_class.perform_later(opts) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class)
      .with(opts)
      .on_queue('default')
  end

  it 'executes perform' do
    attach_opts = opts.dup
    attach_opts[:file] = file
    attach_opts.delete(:file_id)
    expect(ShortFormService).to receive(:attach_file).with(attach_opts)
    perform_enqueued_jobs { job }
    # check that file has now been deleted, we are unable to find it in the DB
    expect { file.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
