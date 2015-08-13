require 'spec_helper'
require 'shared/push_and_pull'

# TODO push and pull
# TODO make orphan stuff work for deleted branches
describe 'Abort and retry a job', type: :feature do
  let :abort_and_retry_job do
    'Abort and Retry Demo'
  end

  it "Running, and then aborting a job ends in the state 'aborted' " \
    ",and then retrying the job ends in the state 'passed'" do
    setup_signin_waitforcommits
    run_job_on_last_commit abort_and_retry_job
    wait_until do
      all("ul.trials li.trial[data-state='executing']").count > 0
    end
    click_on 'Abort'
    expect(first("ul.trials li.trial[data-state='aborting']")).to be
    wait_for_job_state abort_and_retry_job, 'aborting'
    wait_for_job_state abort_and_retry_job, 'aborted'
    expect(all('ul.trials li.trial').map { |x| x['data-state'] } \
           .all? { |x| x == 'aborted' }).to be true
    click_on 'Retry & Resume'
    wait_for_job_state abort_and_retry_job, 'passed', wait_time: 90
  end

  it 'Running a job and then orphan/detach the commit result in ' \
    'the job having been aborted' do
    setup_signin_waitforcommits
    expect(Helpers::DemoRepo.create_a_new_branch_and_commit_cmd(
             'orphaned_abort_test', 'asdfasdfas')).to pass_execution
    wait_until { page.has_content?('orphaned_abort_test') }
    run_job_on_last_commit abort_and_retry_job
    wait_until do
      all("ul.trials li.trial[data-state='executing']").count > 0
    end
    expect(Helpers::DemoRepo.delete_branch_cmd \
             'orphaned_abort_test').to pass_execution
    wait_for_job_state abort_and_retry_job, 'aborted'
  end
end
