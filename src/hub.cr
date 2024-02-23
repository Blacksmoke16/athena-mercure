require "./update"
require "./token_provider"

module HubInterface
  abstract def url : String
  abstract def public_url : String
  abstract def token_provider : TokenProviderInterface
  abstract def token_factory : TokenFactoryInterface?
  abstract def publish(update : Update) : String
end

@[ADI::Register(_url: ENV["MERCURE_URL"])]
class Hub
  include HubInterface

  getter url : String
  getter token_provider : TokenProviderInterface
  getter token_factory : TokenFactoryInterface?

  @public_url : String?

  def initialize(
    @url : String,
    @token_provider : TokenProviderInterface,
    @public_url : String? = nil,
    @token_factory : TokenFactoryInterface? = nil
  )
  end

  def public_url : String
    @public_url || @url
  end

  def publish(update : Update) : String
    HTTP::Client.post(
      @url,
      headers: HTTP::Headers{
        "Authorization" => "Bearer #{@token_provider.jwt}",
      },
      form: URI::Params.build do |form|
        self.encode form, update
      end
    ).body
  end

  private def encode(form : URI::Params::Builder, update : Update) : Nil
    form.add "topic", update.topics
    form.add "data", update.data

    if update.private?
      form.add "private", "on"
    end

    if id = update.id
      form.add "id", id
    end

    if type = update.type
      form.add "type", type
    end

    if retry = update.retry
      form.add "retry", retry.to_s
    end
  end
end
