import { call } from "@autumngmod/cream-api";
import { useEffect, useState } from "react";

export default function App() {
  const [username, setUsername] = useState("nil");

  useEffect(() => {
    const getUsername = async () => {
      let username: string = await call("getUsername", "hi");

      console.log(`username is ${username}`);

      setUsername(username)
    }

    getUsername();
  }, [])

  return (
    <div className="block">username is {username}</div>
  )
}