import Fluent
import FluentPostgresDriver
import Vapor

/// Called before your application initializes.
func configure(_ app: Application) {
    /// Register providers first
    app.provider(FluentProvider())

    /// Register routes
    app.register(extension: Routes.self) { r, c in
        try routes(r, c)
    }

    /// Register middleware
    app.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()
        
        // Serves files from `Public/` directory
        /// middlewares.use(FileMiddleware.self)
        
        // Catches errors and converts to HTTP response
        middlewares.use(c.make(ErrorMiddleware.self))
        
        return middlewares
    }

    app.register(Database.self) { c in
        return c.make(Databases.self).database(.psql)!
    }
    app.register(extension: Databases.self) { dbs, c in
        dbs.postgres(configuration: c.make(), on: app.client.eventLoopGroup)
    }

    app.register(PostgresConfiguration.self) { c in
        return .init(hostname: "vapor", username: "vapor", password: "vapor")
    }

    app.register(Migrations.self) { c in
        var migrations = Migrations()
        migrations.add(CreateTodo(), to: .psql)
        return migrations
    }
}
