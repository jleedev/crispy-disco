use actix_web::{get, App, HttpServer, Responder};
use anyhow::Context;
use lambda_web::{is_running_on_lambda, run_actix_on_lambda};

use std::env::{var, VarError::NotPresent};

#[get("/")]
async fn hello() -> impl Responder {
    format!("hello, world!\n")
}

#[actix_web::main]
async fn main() -> Result<(), Box<dyn std::error::Error + Sync + Send>> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .with_target(false)
        .without_time()
        .init();
    let factory = move || App::new().service(hello);
    if is_running_on_lambda() {
        run_actix_on_lambda(factory).await?;
    } else {
        let port: u16 = match var("PORT") {
            Ok(s) => s.parse().context("PORT")?,
            Err(NotPresent) => 8080,
            Err(e) => Err(e).context("PORT")?,
        };
        let listen = ("::", port);
        HttpServer::new(factory)
            .bind(listen)
            .with_context(|| format!("Binding to {listen:?}"))?
            .run()
            .await?;
    }
    Ok(())
}
