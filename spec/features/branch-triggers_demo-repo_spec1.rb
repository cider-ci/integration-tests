require 'spec_helper'

describe " Triggering jobs via branch updates with respect of
  matches in the project and repository.  ".strip_heredoc, type: :feature do

  let :prerequisite_name do
    'Jobs - Dependencies and Triggers - Prerequisite'
  end

  before :each do
    setup_signin_waitforcommits
  end


  describe "Trigger defined on the repository
  with unmodified repository match and very short max_commit_age".strip_heredoc do

    before :each do
      click_on 'Projects'
      wait_until { page.has_content? 'Demo Project'}
      click_on "Demo Project"
      click_on "Edit"
      find('input#branch_trigger_max_commit_age').set '0 Seconds'
      find("[type='submit']").click
      wait_until(10) { first(".modal") }
      wait_until(10) { ! first(".modal") }
      wait_until(10) { page.has_content? '0 Seconds' }
    end

    it "the job will not be created automatically
    even when an appropriate branch update is pushed".strip_heredoc do
      sleep 15
      expect(Helpers::DemoRepo.create_new_branch('trigger-prerequisite')) \
        .to pass_execution
      first("a",text: "Workspace").click
      sleep 30
      expect(page).not_to have_selector(".job[data-name='#{prerequisite_name}']")
    end
  end

end
