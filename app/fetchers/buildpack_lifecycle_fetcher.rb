module VCAP::CloudController
  class BuildpackLifecycleFetcher
    class << self
      def fetch(buildpack_names, stack_name)
        {
          stack: Stack.find(name: stack_name),
          buildpack_infos: ordered_buildpacks(buildpack_names, stack_name),
        }
      end

      private

      ## NOTE: if a requested system buildpack is not on the requested stack,
      ##       the BuildpackInfo object will have a name and not a record (even
      ##       though the buildpack exists). At this point the error returned
      ##       to the user will probably be VERY confusing
      #
      # XTEAM TODO: Can we use tests to make the above comment obsolete?
      # See the github conversation for more details
      # Why not check to make sure that requested system buildpack is not on the requested stack, and if not, then throw a reasonable error?

      def ordered_buildpacks(buildpack_names, stack_name)
        buildpacks = Buildpack.where(name: buildpack_names, stack: stack_name).all

        buildpack_names.map do |buildpack_name|
          buildpack_record = buildpacks.find { |b| b.name == buildpack_name }
          BuildpackInfo.new(buildpack_name, buildpack_record)
        end
      end
    end
  end
end
