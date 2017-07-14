Feature: Short Form Application - Live/Work Preference
    As a web user
    I should be able to claim the Live/Work preference while filling out a short form application
    In order to increase my chances of getting an affordable housing unit

    Scenario: Live preference only appears if applicant or household members have an address in SF
      # Just me and I don't live or work in SF
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Frank Underwood"
      And I fill out the Contact page with a non-SF address
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I continue past the Lottery Preferences intro
      Then I should not see either the Live in SF Preference or Work in SF Preference
      # I don't live in SF but my roommate does
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Frank Underwood"
      And I fill out the Contact page with a non-SF address
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate living with other people
      And I open the household member form
      And I add an SF-based household member
      And I confirm my address
      And I indicate being done adding people
      And I continue past the Lottery Preferences intro
      Then I should see the Live in SF Preference
      # I live in SF
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Claire Underwood"
      And I fill out the Contact page with an SF address
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I continue past the Lottery Preferences intro
      Then I should see the Live in SF Preference

    Scenario: Work preference only appears if applicant or household member select "Yes" to work in SF question
      # Just me and I don't live in SF but I work there
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Frank Underwood"
      And I fill out the Contact page with a non-SF address that works in SF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I continue past the Lottery Preferences intro
      Then I should see the Work in SF Preference
      # I don't live or work in SF but my housemate works in SF
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Frank Underwood"
      And I fill out the Contact page with a non-SF address
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate living with other people
      And I open the household member form
      And I add a non-SF household member who works in SF
      And I confirm my address
      And I indicate being done adding people
      And I continue past the Lottery Preferences intro
      Then I should see the Work in SF Preference

    Scenario: Both Live and Work preference appear if applicant or household member indicate that both are true
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Frank Underwood"
      And I fill out the Contact page with a non-SF address that works in SF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate living with other people
      And I open the household member form
      And I add an SF-based household member
      And I confirm my address
      And I indicate being done adding people
      And I continue past the Lottery Preferences intro
      And I opt out of NRHP preference
      Then I should see both the Live and Work in SF Preferences

    Scenario: Opting in to live/work then saying no to workInSf then uploading proof
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Jane Doe"
      And I fill out the Contact page with an address (non-NRHP match) and WorkInSF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I continue past the Lottery Preferences intro
      And I select "Jane Doe" for "Live in San Francisco" in Live/Work preference
      And I go back to the Contact page and change WorkInSF to No
      And I go back to the Live/Work preference page
      Then I should still see the single Live in San Francisco preference selected
      When I upload a "Gas bill" as my proof of preference
      Then I should see the successful file upload info
      When I click the Next button on the Live/Work Preference page
      Then I should see the Preferences Programs screen

    Scenario: Selecting live/work member, going back and forth from previous page, changing name
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Jane Doe"
      And I fill out the Contact page with an address (NRHP match) and WorkInSF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I continue past the Lottery Preferences intro
      And I opt out of NRHP preference
      And I select "Jane Doe" for "Live in San Francisco" in Live/Work preference
      And I use the browser back button
      And I go back to the Live/Work preference page
      Then I should still see the preference options and uploader input visible
      # Finish the application and make sure a name change doesn't unclaim the preference
      When I upload a "Gas bill" as my proof of preference
      And I don't choose COP/DTHP preferences
      And I indicate having vouchers
      And I fill out my income as "25000"
      And I fill out the optional survey
      And I navigate to the "You" section
      And I fill out the Name page as "Harper Lee"
      And I navigate to the "Review" section
      And I fill out the optional survey
      Then I should see "Live in San Francisco" preference claimed for "Harper Lee"
