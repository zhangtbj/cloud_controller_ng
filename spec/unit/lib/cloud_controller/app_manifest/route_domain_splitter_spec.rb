require 'spec_helper'
require 'cloud_controller/app_manifest/route_domain_splitter'

module VCAP::CloudController
  RSpec.describe RouteDomainSplitter do

    context 'when there is a valid host and domain' do
      it 'splits a URL string into its route components' do
        url = 'http://host.sub.some-domain.com:9101/path'
        expect(RouteDomainSplitter.split(url)).to eq(
          protocol: 'http',
          potential_domains: [
            'some-domain.com',
            'sub.some-domain.com',
            'host.sub.some-domain.com'
          ],
          port: 9101,
          path: '/path'
        )
      end
    end

    # context 'when there is no host' do
    #   it 'returns an error' do
    #     url = 'http://some-domain.com:'
    #     expect(RouteDomainSplitter.split(url)).to eq(
    #       protocol: 'http',
    #       host: '',
    #       domain: 'some-domain.com',
    #     )
    #   end
    # end
    #
    # context 'when the host format is invalid' do
    #   it 'returns an error' do
    #     url = 'http://extra.host.some-domain.com:'
    #     expect(RouteDomainSplitter.split(url)).to eq(
    #       protocol: 'http',
    #       host: '',
    #       domain: 'some-domain.com',
    #     )
    #   end
    # end

  end
end
