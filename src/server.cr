require "athena"
require "jwt"

require "./hub"

def ATH::Config::CORS.configure : ATH::Config::CORS?
  new(
    allow_origin: %w(http://localhost:8080),
    expose_headers: %w(link)
  )
end

@[ADI::Register]
class BookController < ATH::Controller
  private COOKIE_NAME = "mercureAuthorization"

  def initialize(@hub : HubInterface); end

  @[ARTA::Get("/book/{id}")]
  def book(id : Int32) : ATH::Response
    # Emit an update for the book we should be fetching
    # It is private so only clients that are authed will receive the update
    update = Update.new(
      "https://example.com/book/#{id}",
      {status: "Secretly checked out #{id}"}.to_json,
      private: true
    )

    # Add a link header to enable discovery.
    # Allows the client to know where the source of events is from
    #
    # TODO: Include a rel=self Link header to denote the topic
    headers = ATH::Response::Headers{
      "link" => %(<#{@hub.public_url}>; rel="mercure"),
    }

    # Set a cookie that'll be used for authentication from clients fetching a book
    headers.cookies << HTTP::Cookie.new(
      COOKIE_NAME,

      # Allow the client to subscribe/publish to anything.
      # Probably should be better scoped?
      @hub.token_factory.not_nil!.create(["*"], ["*"]),

      # Use short lived tokens
      max_age: 1.hour,
      path: URI.parse(@hub.public_url).path,
      secure: false,
      http_only: true,
      samesite: :strict
    )

    # Return the ID of the published event as the response body,
    # including the customized headers/cookie
    ATH::Response.new(
      @hub.publish(update),
      headers: headers
    )
  end
end

ATH.run
