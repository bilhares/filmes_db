class ApplicationController < ActionController::API
    def api_key
        @api_key = '2f7a45be9a8e5e0d885bdb059ca2f436'
    end
    def base_url
        @base_url = 'https://api.themoviedb.org/3'
    end
end
