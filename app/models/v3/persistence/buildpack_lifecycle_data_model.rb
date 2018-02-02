require 'cloud_controller/diego/lifecycles/lifecycles'
require 'utils/uri_utils'

module VCAP::CloudController
  class BuildpackLifecycleDataModel < Sequel::Model(:buildpack_lifecycle_data)
    LIFECYCLE_TYPE = Lifecycles::BUILDPACK

    many_to_one :droplet,
      class: '::VCAP::CloudController::DropletModel',
      key: :droplet_guid,
      primary_key: :guid,
      without_guid_generation: true

    many_to_one :build,
      class: '::VCAP::CloudController::BuildModel',
      key: :build_guid,
      primary_key: :guid,
      without_guid_generation: true

    many_to_one :app,
      class: '::VCAP::CloudController::AppModel',
      key: :app_guid,
      primary_key: :guid,
      without_guid_generation: true

    one_to_many :buildpack_lifecycle_buildpacks,
      class: '::VCAP::CloudController::BuildpackLifecycleBuildpackModel',
      key: :buildpack_lifecycle_data_guid,
      primary_key: :guid,
      order: :id
    plugin :nested_attributes
    nested_attributes :buildpack_lifecycle_buildpacks, destroy: true
    add_association_dependencies buildpack_lifecycle_buildpacks: :destroy

    def buildpacks
      self.buildpack_lifecycle_buildpacks.map(&:name)
    end

    def buildpack_models
      if self.buildpack_lifecycle_buildpacks.present?
        self.buildpack_lifecycle_buildpacks.map do |buildpack|
          Buildpack.find(name: buildpack.name) || CustomBuildpack.new(buildpack.name)
        end
      else
        [AutoDetectionBuildpack.new]
      end
    end

    def buildpacks=(new_buildpacks)
      new_buildpacks ||= []

      buildpacks_to_remove = self.buildpack_lifecycle_buildpacks.map { |bp| { id: bp.id, _delete: true } }
      buildpacks_to_add = new_buildpacks.map { |buildpack_url| attributes_from_name(buildpack_url) }
      self.buildpack_lifecycle_buildpacks_attributes = buildpacks_to_add + buildpacks_to_remove
    end

    def using_custom_buildpack?
      buildpack_lifecycle_buildpacks.any?(&:custom?)
    end

    def first_custom_buildpack_url
      buildpack_lifecycle_buildpacks.find(&:custom?)&.buildpack_url
    end

    def to_hash
      {
        buildpacks: buildpacks.map { |buildpack| CloudController::UrlSecretObfuscator.obfuscate(buildpack) },
        stack: stack
      }
    end

    def validate
      if app && (build || droplet)
        errors.add(:lifecycle_data, 'Must be associated with an app OR a build+droplet, but not both')
      end
    end

    private

    def attributes_from_name(name)
      if UriUtils.is_buildpack_uri?(name)
        { buildpack_url: name, admin_buildpack_name: nil }
      else
        { buildpack_url: nil, admin_buildpack_name: name }
      end
    end
  end
end
