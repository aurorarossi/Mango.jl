using Mango
using Test
using Parameters

import Mango.AgentRole.handle_event

@agent struct RoleTestAgent
    counter::Integer
end

@role struct RoleTestRole
    counter::Integer
    src::Union{Role,Nothing}
end

struct TestEvent
end

function handle_event(role::Role, src::Role, event::TestEvent)
    role.counter = 1
    role.src = src
end

@testset "RoleEmitEventSimpleHandle" begin
    agent = RoleTestAgent(0)
    role1 = RoleTestRole(0, nothing)
    role2 = RoleTestRole(0, nothing)
    add(agent, role1)
    add(agent, role2)

    emit_event(role1, TestEvent())

    @test role1.counter == 1
    @test role2.counter == 1
    @test role1.src == role1
    @test role2.src == role1
end

struct TestEvent2
    id::Int64
end

function custom_handler(role::Role, src::Role, event::Any)
    role.counter += event.id
    role.src = src
end

@testset "RoleEmitEventSubHandle" begin
    agent = RoleTestAgent(0)
    role1 = RoleTestRole(0, nothing)
    role2 = RoleTestRole(0, nothing)
    add(agent, role1)
    add(agent, role2)
    subscribe_event(role1, TestEvent2, (src, event) -> event.id == 2, custom_handler)

    emit_event(role2, TestEvent2(2))
    emit_event(role2, TestEvent2(3))

    @test role1.counter == 2
    @test role1.src == role2
end

struct TestModel
    c::Int64
end
TestModel() = TestModel(42)

@testset "RoleGetModel" begin
    agent = RoleTestAgent(0)
    role1 = RoleTestRole(0, nothing)
    role2 = RoleTestRole(0, nothing)
    add(agent, role1)
    add(agent, role2)

    shared_model = get_model(role1, TestModel)
    shared_model2 = get_model(role2, TestModel)

    @test shared_model.c == 42
    @test shared_model == shared_model2
end

