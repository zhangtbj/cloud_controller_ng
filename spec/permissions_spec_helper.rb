READ_ONLY_PERMS = {
  'admin' => 200,
  'admin_read_only' => 200,
  'global_auditor' => 200,
  'space_developer' => 200,
  'space_manager' => 200,
  'space_auditor' => 200,
  'org_manager' => 200,
  'org_auditor' => 404,
  'org_billing_manager' => 404,
}.freeze

READ_AND_WRITE_PERMS = {
  'admin' => 200,
  'admin_read_only' => 403,
  'global_auditor' => 403,
  'space_developer' => 200,
  'space_manager' => 403,
  'space_auditor' => 403,
  'org_manager' => 403,
  'org_auditor' => 404,
  'org_billing_manager' => 404,
}.freeze

RSpec.shared_examples "read only endpoint" do
  describe "permissions" do
    READ_ONLY_PERMS.each do |role, expected_return_value|
      describe "as an #{role}" do
        it "returns #{expected_return_value}" do
          set_current_user_as_role(role: role, org: org, space: space, user: user)
          api_call.call

          expect(response.status).to eq(expected_return_value), "role #{role}: expected  #{expected_return_value}, got: #{response.status}"
        end
      end
    end
  end
end

RSpec.shared_examples "read and write endpoint" do
  describe "permissions" do
    READ_AND_WRITE_PERMS.each do |role, expected_return_value|
      describe "as an #{role}" do
        it "returns #{expected_return_value}" do
          set_current_user_as_role(role: role, org: org, space: space, user: user)
          api_call.call

          expect(response.status).to eq(expected_return_value), "role #{role}: expected  #{expected_return_value}, got: #{response.status}"
        end
      end
    end
  end
end
