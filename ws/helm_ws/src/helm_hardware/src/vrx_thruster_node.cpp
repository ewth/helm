#include <cstdio>
#include <chrono>

#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/float64.hpp"
#include "helm_msgs/msg/thrust_command.hpp"

/**
 * @file vrx_thruster_node.cpp
 * @brief VRX Thruster Node
 *
 * VRX backend for the thruster abstraction.
 * Consumes helm_msgs/ThrustCommand messages; emits per-thruster Float64 on VRX's thruster topics.
 *
 * @author Ewan Thompson
 * @date 2024-06-10
 */

using namespace std::chrono_literals;

class VrxThrusterNode : public rclcpp::Node
{

private:
    void on_command(const helm_msgs::msg::ThrustCommand &msg)
    {
        last_command_ = now();
        publish(msg.left, msg.right);
    }

    void on_watchdog()
    {
        if (now() - last_command_ > timeout_)
        {
            watchdog_hit_++;
            std::cout << "WARN: VrxThrusterNode watchdog " << watchdog_hit_ << std::endl;
            publish(0.0, 0.0);
        }
    }

    void publish(double left, double right)
    {
        std_msgs::msg::Float64 l, r;
        l.data = std::clamp(left, -max_thrust_, max_thrust_);
        r.data = std::clamp(right, -max_thrust_, max_thrust_);
        left_thrust_pub_->publish(l);
        right_thrust_pub_->publish(r);
    }

    double max_thrust_{};
    rclcpp::Duration timeout_{0, 0};
    rclcpp::Time last_command_;
    rclcpp::Publisher<std_msgs::msg::Float64>::SharedPtr left_thrust_pub_, right_thrust_pub_;
    rclcpp::Subscription<helm_msgs::msg::ThrustCommand>::SharedPtr sub_;
    rclcpp::TimerBase::SharedPtr watchdog_;
    std::uint32_t watchdog_hit_{0};

public:
    VrxThrusterNode() : Node("vrx_thruster_node")
    {
        // /wamv/thrusters/{left,right}/{pos,thrust}
        // @todo: review pos usage
        const auto left_thrust_topic = declare_parameter<std::string>("left_thrust_topic", "/wamv/thrusters/left/thrust");
        const auto right_thrust_topic = declare_parameter<std::string>("right_thrust_topic", "/wamv/thrusters/right/thrust");

        // QoS 10 is implicitly keep last
        left_thrust_pub_ = create_publisher<std_msgs::msg::Float64>(left_thrust_topic, 10);
        right_thrust_pub_ = create_publisher<std_msgs::msg::Float64>(right_thrust_topic, 10);

        // Arbitrary for now
        // @todo: verify actual max thrust of WAMV
        max_thrust_ = declare_parameter<double>("max_thrust", 1000.0);

        sub_ = create_subscription<helm_msgs::msg::ThrustCommand>("thrust_command", 10, std::bind(&VrxThrusterNode::on_command, this, std::placeholders::_1));

        timeout_ = rclcpp::Duration::from_seconds(declare_parameter<double>("command_timeout", 0.5));
        last_command_ = now();
        watchdog_ = create_wall_timer(100ms, std::bind(&VrxThrusterNode::on_watchdog, this));
    };
};

int main(int argc, char **argv)
{
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<VrxThrusterNode>());
    rclcpp::shutdown();
    return 0;
}
