RSpec.shared_examples 'an access class' do |operation, table|
  table.each do |role, expected_return_value|
    describe "#{operation}? and #{operation}_with_token?" do
      describe "as a(n) #{role}" do
        it "returns #{expected_return_value}" do
          set_current_user_as_role(role: role, org: org, space: space, user: user)
          actual = subject.can?("#{operation}_with_token".to_sym, object) &&
            subject.can?(operation, object)

          expect(actual).to eq(expected_return_value),
            "role #{role}: expected #{expected_return_value}, got: #{actual}"
        end
      end
    end
  end
end
